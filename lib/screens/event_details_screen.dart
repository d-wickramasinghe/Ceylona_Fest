import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../services/db.dart';
import '../services/event_utils.dart';
import 'calendar_reminders_screen.dart';
import 'map_directions_screen.dart';
import 'schedule_facilities_screen.dart';
import 'event_gallery_screen.dart';
import '../widgets/ceylona_bottom_navigation.dart';
import '../widgets/event_image.dart';
import '../theme/app_theme.dart';

class EventDetailsScreen extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;
  const EventDetailsScreen({super.key, required this.id, required this.data});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final ctrl = TextEditingController();
  Uint8List? selectedCommentImage;
  String? selectedCommentExtension;
  bool submittingComment = false;

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickCommentImage() async {
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
    setState(() {
      selectedCommentImage = bytes;
      selectedCommentExtension = image.name.split('.').last.toLowerCase();
    });
  }

  Future<String?> _uploadCommentImage(Uint8List? bytes, String? extension) =>
      bytes == null
          ? Future.value(null)
          : Db.uploadImage(bytes, extension ?? 'jpg',
              folder: 'events/${widget.id}/comments');

  Future<void> _submitComment() async {
    final text = ctrl.text.trim();
    if (text.isEmpty && selectedCommentImage == null) return;
    setState(() => submittingComment = true);
    try {
      final imageUrl = await _uploadCommentImage(
          selectedCommentImage, selectedCommentExtension);
      await Db.addComment(widget.id, text, imageUrl: imageUrl);
      ctrl.clear();
      if (mounted) {
        setState(() {
          selectedCommentImage = null;
          selectedCommentExtension = null;
        });
      }
    } on FirebaseException catch (error) {
      _showCommentError(error.message ?? 'Could not post comment');
    } on StateError catch (error) {
      _showCommentError(error.message);
    } finally {
      if (mounted) setState(() => submittingComment = false);
    }
  }

  void _showCommentError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _editComment(
      QueryDocumentSnapshot<Map<String, dynamic>> comment) async {
    final text = TextEditingController(text: comment.data()['text'] ?? '');
    String? imageUrl = comment.data()['imageUrl']?.toString();
    Uint8List? replacementImage;
    String? replacementExtension;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit comment'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: text,
                maxLines: 4,
                decoration: const InputDecoration(
                    hintText: 'Your comment', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            if (imageUrl != null && replacementImage == null)
              Image.network(imageUrl!, height: 90, fit: BoxFit.cover),
            if (replacementImage != null)
              Image.memory(replacementImage!, height: 90, fit: BoxFit.cover),
            TextButton.icon(
                onPressed: () async {
                  final image = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                      maxWidth: 1400);
                  if (image == null) return;
                  final bytes = await image.readAsBytes();
                  if (bytes.length > 5 * 1024 * 1024) return;
                  setDialogState(() {
                    replacementImage = bytes;
                    replacementExtension =
                        image.name.split('.').last.toLowerCase();
                  });
                },
                icon: const Icon(Icons.image_outlined),
                label: const Text('Replace image')),
            if (imageUrl != null || replacementImage != null)
              TextButton(
                  onPressed: () => setDialogState(() {
                        imageUrl = null;
                        replacementImage = null;
                      }),
                  child: const Text('Remove image')),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Save')),
          ],
        ),
      ),
    );
    if (saved != true ||
        (text.text.trim().isEmpty &&
            imageUrl == null &&
            replacementImage == null)) {
      text.dispose();
      return;
    }

    try {
      final uploaded =
          await _uploadCommentImage(replacementImage, replacementExtension);
      await Db.updateComment(widget.id, comment.id,
          text: text.text, imageUrl: uploaded ?? imageUrl);
    } on FirebaseException catch (error) {
      _showCommentError(error.message ?? 'Could not update comment');
    } on StateError catch (error) {
      _showCommentError(error.message);
    } finally {
      text.dispose();
    }
  }

  Future<void> _replyToComment(
      QueryDocumentSnapshot<Map<String, dynamic>> comment) async {
    final reply = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reply to comment'),
        content: TextField(
          controller: reply,
          maxLines: 4,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Write your reply',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reply'),
          ),
        ],
      ),
    );
    if (saved != true || reply.text.trim().isEmpty) {
      reply.dispose();
      return;
    }
    try {
      await Db.replyToComment(widget.id, comment.id, reply.text);
    } on FirebaseException catch (error) {
      _showCommentError(error.message ?? 'Could not send reply');
    } on StateError catch (error) {
      _showCommentError(error.message);
    } finally {
      reply.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18)),
        title: Text(widget.data['title'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            Stack(children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: EventImage(
                      url: widget.data['imageUrl']?.toString(),
                      height: 220,
                      borderRadius: BorderRadius.circular(14))),
              Positioned(
                  right: 10,
                  bottom: 10,
                  child: FilledButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EventGalleryScreen(
                                  eventId: widget.id,
                                  eventTitle:
                                      widget.data['title']?.toString() ??
                                          'Event',
                                  mode: GalleryMode.seeker))),
                      icon: const Icon(Icons.photo_library_outlined, size: 16),
                      label: const Text('View Photo Gallery'),
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.primaryDark))),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Chip(
                  label: Text(widget.data['category']?.toString() ?? 'Event'),
                  visualDensity: VisualDensity.compact),
              const SizedBox(width: 8),
              const Icon(Icons.verified, size: 16, color: AppColors.success),
              const SizedBox(width: 4),
              const Text('Verified organizer', style: TextStyle(fontSize: 12)),
            ]),
            Text(widget.data['title']?.toString() ?? 'Event',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Card(
                color: const Color(0xfffff3c4),
                child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Row(children: [
                      const Icon(Icons.confirmation_number_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text('Ticket price',
                                style: TextStyle(fontSize: 11)),
                            Text(widget.data['price']?.toString() ?? 'Free',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800)),
                          ])),
                      const Chip(
                          label: Text('Presale active'),
                          visualDensity: VisualDensity.compact),
                    ]))),
            const SizedBox(height: 8),
            _EventInfoTile(
                icon: Icons.calendar_month_outlined,
                title: '${widget.data['date'] ?? ''}',
                subtitle: widget.data['time']?.toString() ?? ''),
            _EventInfoTile(
                icon: Icons.location_on_outlined,
                title: widget.data['location']?.toString() ?? 'Location',
                subtitle: widget.data['address']?.toString() ?? 'Sri Lanka'),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                  child: _ActionButton(
                      icon: Icons.map_outlined,
                      label: 'View Map',
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  MapDirectionsScreen(event: widget.data))))),
              const SizedBox(width: 8),
              Expanded(
                  child: _ActionButton(
                      icon: Icons.alarm_add_outlined,
                      label: 'Set Reminder',
                      dark: true,
                      onPressed: () => _setReminder(context))),
              const SizedBox(width: 8),
              Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: Db.saved(),
                      builder: (context, snapshot) {
                        final isSaved = snapshot.data?.docs
                                .any((doc) => doc.id == widget.id) ??
                            false;
                        return _ActionButton(
                            icon: isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            label: isSaved ? 'Saved' : 'Save',
                            onPressed: isSaved
                                ? null
                                : () async {
                                    await Db.saveEvent(widget.id, widget.data);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text('Event saved')));
                                    }
                                  });
                      })),
            ]),
            const SizedBox(height: 22),
            const Text('About the Event',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
                widget.data['description']?.toString() ??
                    'No description provided.',
                style: const TextStyle(height: 1.45)),
            if (widget.data['transportInfo']?.toString().isNotEmpty ==
                true) ...[
              const SizedBox(height: 18),
              const Text('Getting there',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(widget.data['transportInfo'].toString()),
            ],
            if (widget.data['parkingInfo']?.toString().isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text('Parking: ${widget.data['parkingInfo']}',
                  style: const TextStyle(color: Colors.black54)),
            ],
            OutlinedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('View Schedule & Facilities'),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          ScheduleFacilitiesScreen(eventId: widget.id))),
            ),
            const Divider(height: 32),
            const Text('Discussion',
                style: TextStyle(fontWeight: FontWeight.bold)),
            if (selectedCommentImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Stack(children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(selectedCommentImage!,
                          height: 90, width: 120, fit: BoxFit.cover)),
                  Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                          onPressed: () =>
                              setState(() => selectedCommentImage = null),
                          icon: const Icon(Icons.close, color: Colors.white)))
                ]),
              ),
            Row(children: [
              Expanded(
                  child: TextField(
                      controller: ctrl,
                      decoration:
                          const InputDecoration(hintText: 'Add a comment'))),
              IconButton(
                  tooltip: 'Add image',
                  icon: const Icon(Icons.image_outlined),
                  onPressed: submittingComment ? null : _pickCommentImage),
              IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: submittingComment ? null : _submitComment)
            ]),
            StreamBuilder(
              stream: Db.comments(widget.id),
              builder: (c, s) {
                if (!s.hasData) return const SizedBox();
                return Column(children: [
                  for (final d in s.data!.docs)
                    Card(
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(d['userName'] ?? ''),
                                    subtitle: Text(d['text'] ?? ''),
                                    trailing: d['userId'] == uid ||
                                            widget.data['organizerId'] == uid
                                        ? Wrap(children: [
                                            if (widget.data['organizerId'] ==
                                                    uid &&
                                                d['userId'] != uid)
                                              IconButton(
                                                tooltip: 'Reply to comment',
                                                icon: const Icon(
                                                    Icons.reply_outlined),
                                                onPressed: () =>
                                                    _replyToComment(d),
                                              ),
                                            if (d['userId'] == uid)
                                              IconButton(
                                                tooltip: 'Edit comment',
                                                icon: const Icon(
                                                    Icons.edit_outlined),
                                                onPressed: () =>
                                                    _editComment(d),
                                              ),
                                            if (d['userId'] == uid)
                                              IconButton(
                                                  tooltip: 'Delete comment',
                                                  icon: const Icon(
                                                      Icons.delete_outline),
                                                  onPressed: () =>
                                                      Db.deleteComment(
                                                          widget.id, d.id)),
                                          ])
                                        : null,
                                  ),
                                  if (d
                                          .data()['replyText']
                                          ?.toString()
                                          .trim()
                                          .isNotEmpty ==
                                      true)
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(top: 6),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: .07),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Organizer reply: ${d.data()['replyText']}',
                                      ),
                                    ),
                                  if (d
                                          .data()['imageUrl']
                                          ?.toString()
                                          .isNotEmpty ==
                                      true)
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                            d.data()['imageUrl'].toString(),
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover))
                                ])))
                ]);
              },
            ),
          ]),
      bottomNavigationBar: const CeylonaBottomNavigation(selectedIndex: 0),
    );
  }

  Future<void> _setReminder(BuildContext context) async {
    final eventTime = parseEventDateTime(widget.data);
    if (eventTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Add a valid event date and time first.')));
      return;
    }
    await Db.saveEvent(widget.id, widget.data);
    if (!context.mounted) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CalendarRemindersScreen(
                  eventId: widget.id,
                  eventData: widget.data,
                )));
  }
}

class _EventInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EventInfoTile(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: .14),
              child: Icon(icon, color: AppColors.primaryDark, size: 19)),
          title: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        ),
      );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool dark;
  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.onPressed,
      this.dark = false});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 42,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 15),
          label: Text(label, style: const TextStyle(fontSize: 10)),
          style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              backgroundColor: dark ? AppColors.primaryDark : AppColors.primary,
              foregroundColor: dark ? Colors.white : AppColors.primaryDark),
        ),
      );
}
