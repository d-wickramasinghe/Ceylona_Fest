import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/db.dart';
import 'organizer_schedule_editor_screen.dart';

enum OrganizerView { dashboard, events, create }

class OrganizerScreen extends StatelessWidget {
  final OrganizerView view;
  const OrganizerScreen({super.key, this.view = OrganizerView.dashboard});

  void form(BuildContext ctx, {String? id, Map<String, dynamic>? d}) {
    final t = TextEditingController(text: d?['title']),
        date = TextEditingController(text: d?['date']),
        time = TextEditingController(text: d?['time']),
        loc = TextEditingController(text: d?['location']),
        price = TextEditingController(text: d?['price']),
        lat = TextEditingController(text: d?['lat']?.toString()),
        lng = TextEditingController(text: d?['lng']?.toString()),
        transport = TextEditingController(text: d?['transportInfo']),
        parking = TextEditingController(text: d?['parkingInfo']),
        desc = TextEditingController(text: d?['description']);
    String cat = d?['category'] ?? 'Music';
    XFile? selectedImage;
    Uint8List? selectedImageBytes;
    var submitting = false;
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (c, set) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(c).viewInsets.bottom + 16),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(id == null ? 'Create Event' : 'Edit Event',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              TextField(
                  controller: t,
                  decoration: const InputDecoration(labelText: 'Event name')),
              DropdownButtonFormField<String>(
                initialValue: cat,
                items: ['Music', 'Cultural', 'Food', 'Sports', 'University']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => set(() => cat = v!),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Event image',
                    style: Theme.of(c).textTheme.titleSmall),
              ),
              const SizedBox(height: 8),
              if (selectedImageBytes != null || d?['imageUrl'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: selectedImageBytes != null
                        ? Image.memory(selectedImageBytes!, fit: BoxFit.cover)
                        : Image.network(d!['imageUrl'],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image_outlined))),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: submitting
                    ? null
                    : () async {
                        final image = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                          maxWidth: 1600,
                          maxHeight: 1200,
                        );
                        if (image == null) return;
                        final bytes = await image.readAsBytes();
                        if (c.mounted) {
                          set(() {
                            selectedImage = image;
                            selectedImageBytes = bytes;
                          });
                        }
                      },
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(selectedImageBytes == null
                    ? 'Choose image'
                    : 'Change image'),
              ),
              TextField(
                  controller: date,
                  decoration: const InputDecoration(
                      labelText: 'Date (e.g. 2026-10-25)')),
              TextField(
                  controller: time,
                  decoration:
                      const InputDecoration(labelText: 'Time (e.g. 9:00 AM)')),
              TextField(
                  controller: loc,
                  decoration:
                      const InputDecoration(labelText: 'Venue / Location')),
              TextField(
                  controller: lat,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Latitude (optional)')),
              TextField(
                  controller: lng,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Longitude (optional)')),
              TextField(
                  controller: transport,
                  decoration: const InputDecoration(
                      labelText: 'Transport information (optional)')),
              TextField(
                  controller: parking,
                  decoration: const InputDecoration(
                      labelText: 'Parking information (optional)')),
              TextField(
                  controller: price,
                  decoration: const InputDecoration(
                      labelText: 'Ticket price (or Free)')),
              TextField(
                  controller: desc,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: submitting
                    ? null
                    : () async {
                        set(() => submitting = true);
                        try {
                          String? imageUrl = d?['imageUrl']?.toString();
                          if (selectedImage != null &&
                              selectedImageBytes != null) {
                            final extension = selectedImage!.name
                                .split('.')
                                .last
                                .toLowerCase();
                            final contentType = switch (extension) {
                              'png' => 'image/png',
                              'webp' => 'image/webp',
                              _ => 'image/jpeg',
                            };
                            final ref = FirebaseStorage.instance.ref().child(
                                'events/$uid/${DateTime.now().millisecondsSinceEpoch}.$extension');
                            await ref.putData(selectedImageBytes!,
                                SettableMetadata(contentType: contentType));
                            imageUrl = await ref.getDownloadURL();
                          }
                          final data = {
                            'title': t.text,
                            'category': cat,
                            'date': date.text,
                            'time': time.text,
                            'location': loc.text,
                            'lat': double.tryParse(lat.text.trim()),
                            'lng': double.tryParse(lng.text.trim()),
                            'transportInfo': transport.text,
                            'parkingInfo': parking.text,
                            'price': price.text.isEmpty ? 'Free' : price.text,
                            'description': desc.text,
                            if (imageUrl != null && imageUrl.isNotEmpty)
                              'imageUrl': imageUrl,
                          };
                          id == null
                              ? await Db.createEvent(data)
                              : await Db.updateEvent(id, data);
                          if (c.mounted) Navigator.pop(c);
                        } on FirebaseException catch (error) {
                          if (c.mounted) {
                            set(() => submitting = false);
                            ScaffoldMessenger.of(c).showSnackBar(SnackBar(
                                content: Text(
                                    'Could not save event: ${error.message ?? error.code}')));
                          }
                        }
                      },
                child: submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit for approval'),
              )
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (view == OrganizerView.create) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Event')),
        body: Center(
          child: FilledButton.icon(
            onPressed: () => form(context),
            icon: const Icon(Icons.add),
            label: const Text('Start a new event submission'),
          ),
        ),
      );
    }
    if (view == OrganizerView.dashboard) {
      return Scaffold(
        appBar: AppBar(title: Text('Welcome, $userName')),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => form(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Event')),
        body: StreamBuilder(
          stream: Db.myEvents(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data!.docs;
            final published =
                docs.where((doc) => doc.data()['status'] == 'approved').length;
            final pending =
                docs.where((doc) => doc.data()['status'] == 'pending').length;
            return ListView(padding: const EdgeInsets.all(16), children: [
              const Text('Your event activity at a glance',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.7,
                  children: [
                    _DashboardMetric(
                        label: 'Total Events',
                        value: '${docs.length}',
                        icon: Icons.event),
                    _DashboardMetric(
                        label: 'Published',
                        value: '$published',
                        icon: Icons.public),
                    _DashboardMetric(
                        label: 'Pending Review',
                        value: '$pending',
                        icon: Icons.hourglass_top),
                    const _DashboardMetric(
                        label: 'Interested',
                        value: '0',
                        icon: Icons.people_outline),
                  ]),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Manage Events',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                TextButton(onPressed: () {}, child: const Text('See All'))
              ]),
              if (docs.isEmpty) const Text('No events created yet.'),
              for (final doc in docs.take(5))
                Card(
                    child: ListTile(
                        title: Text(doc['title'] ?? 'Untitled event'),
                        subtitle: Text(
                            '${doc['date'] ?? ''} • ${doc['location'] ?? ''}'),
                        trailing:
                            _StatusBadge(status: doc['status'] ?? 'pending'))),
            ]);
          },
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
          title: Text(view == OrganizerView.events
              ? 'My Events'
              : 'Organizer Dashboard')),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => form(context),
          icon: const Icon(Icons.add),
          label: const Text('Create Event')),
      body: StreamBuilder(
        stream: Db.myEvents(),
        builder: (c, s) {
          if (!s.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.data!.docs.isEmpty) {
            return const Center(child: Text('No events created yet'));
          }
          return ListView(children: [
            for (final d in s.data!.docs)
              Card(
                child: ListTile(
                  title: Text(d['title']),
                  subtitle: Text('${d['date']} • Status: ${d['status']}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        icon: const Icon(Icons.schedule),
                        tooltip: 'Schedule',
                        onPressed: () => Navigator.push(
                            c,
                            MaterialPageRoute(
                                builder: (_) => OrganizerScheduleEditorScreen(
                                    eventId: d.id, eventTitle: d['title'])))),
                    IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => form(c, id: d.id, d: d.data())),
                    IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => Db.deleteEvent(d.id)),
                  ]),
                ),
              )
          ]);
        },
      ),
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _DashboardMetric(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Icon(icon, color: Colors.amber.shade800),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ]),
        ),
      );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final approved = status.trim().toLowerCase() == 'approved';
    return Chip(
        label: Text(approved ? 'Published' : 'Pending',
            style: const TextStyle(fontSize: 10)),
        backgroundColor:
            approved ? Colors.green.shade100 : Colors.orange.shade100,
        visualDensity: VisualDensity.compact);
  }
}
