import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/db.dart';
import '../widgets/event_image.dart';

enum GalleryMode { seeker, organizer, admin }

class EventGalleryScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final GalleryMode mode;

  const EventGalleryScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.mode,
  });

  @override
  State<EventGalleryScreen> createState() => _EventGalleryScreenState();
}

class _EventGalleryScreenState extends State<EventGalleryScreen> {
  bool uploading = false;

  Future<void> _upload() async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 1400);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please choose an image smaller than 5 MB')));
      }
      return;
    }
    setState(() => uploading = true);
    try {
      final extension = image.name.split('.').last.toLowerCase();
      final url = await Db.uploadImage(bytes, extension,
          folder: 'events/${widget.eventId}/gallery');
      await Db.addGalleryImage(widget.eventId, url, '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Gallery image sent for admin approval')));
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'Upload failed')));
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final includePending = widget.mode != GalleryMode.seeker;
    final organizerOnly = widget.mode == GalleryMode.organizer;
    return Scaffold(
      appBar: AppBar(title: Text('${widget.eventTitle} Gallery')),
      floatingActionButton: widget.mode == GalleryMode.organizer
          ? FloatingActionButton.extended(
              onPressed: uploading ? null : _upload,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(uploading ? 'Uploading...' : 'Add image'))
          : null,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: Db.eventGallery(widget.eventId,
          includePending: includePending, organizerOnly: organizerOnly),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Could not load gallery: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = [...snapshot.data!.docs]
            ..sort((a, b) {
              final aTime = a.data()['createdAt'] as Timestamp?;
              final bTime = b.data()['createdAt'] as Timestamp?;
              return (bTime?.millisecondsSinceEpoch ?? 0)
                  .compareTo(aTime?.millisecondsSinceEpoch ?? 0);
            });
          if (docs.isEmpty) {
            return Center(
                child: Text(widget.mode == GalleryMode.seeker
                    ? 'No approved gallery images yet.'
                    : 'No gallery images uploaded yet.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisExtent: 250,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final status = data['status']?.toString() ?? 'pending';
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: EventImage(
                          url: data['imageUrl']?.toString(),
                          height: double.infinity,
                          borderRadius: BorderRadius.zero)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                    child: Row(children: [
                      Expanded(child: Text(widget.mode == GalleryMode.seeker ? 'Approved image' : status)),
                      if (widget.mode == GalleryMode.admin && status == 'pending') ...[
                        IconButton(
                            tooltip: 'Approve image',
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => Db.reviewGalleryImage(
                                widget.eventId, doc.id, 'approved')),
                        IconButton(
                            tooltip: 'Reject image',
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => Db.reviewGalleryImage(
                                widget.eventId, doc.id, 'rejected')),
                      ],
                      if (widget.mode == GalleryMode.organizer)
                        IconButton(
                            tooltip: 'Delete image',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => Db.deleteGalleryImage(
                                widget.eventId, doc.id)),
                    ]),
                  ),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
