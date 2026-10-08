import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/db.dart';
import '../theme/app_theme.dart';
import 'organizer_schedule_editor_screen.dart';

enum OrganizerView { dashboard, events, create }

class OrganizerScreen extends StatelessWidget {
  final OrganizerView view;
  const OrganizerScreen({super.key, this.view = OrganizerView.dashboard});

  Future<void> _afterDraftSaved(
      BuildContext context, String eventId, String title) async {
    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Draft saved'),
        content: const Text(
            'Add agenda items and facilities now if this event needs them, or keep it as a draft and publish it later.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'later'),
              child: const Text('Keep as draft')),
          FilledButton.icon(
              onPressed: () => Navigator.pop(dialogContext, 'details'),
              icon: const Icon(Icons.event_note_outlined),
              label: const Text('Add details')),
        ],
      ),
    );
    if (action == 'details' && context.mounted) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => OrganizerScheduleEditorScreen(
                    eventId: eventId,
                    eventTitle: title.isEmpty ? 'Untitled event' : title,
                  )));
    }
  }

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
              Text(id == null ? 'Create Event Draft' : 'Edit Event',
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
                      style: Theme.of(c).textTheme.titleSmall)),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: submitting
                    ? null
                    : () async {
                        final image = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 65,
                          maxWidth: 1200,
                          maxHeight: 900,
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
                child: Container(
                  height: 158,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xfff4f6f9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffd9dde5)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: selectedImageBytes != null
                      ? Image.memory(selectedImageBytes!, fit: BoxFit.cover)
                      : d?['imageUrl'] != null
                          ? Image.network(d!['imageUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image_outlined)))
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 38, color: Color(0xff667085)),
                                SizedBox(height: 8),
                                Text('Tap to add event image',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xff344054))),
                                SizedBox(height: 4),
                                Text('JPG, PNG, or WebP under 5 MB',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xff667085))),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: submitting
                    ? null
                    : () async {
                        final image = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 65,
                          maxWidth: 1200,
                          maxHeight: 900,
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
                label: Text(selectedImageBytes == null && d?['imageUrl'] == null
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
                            const maxUploadBytes = 5 * 1024 * 1024;
                            if (selectedImageBytes!.length > maxUploadBytes) {
                              throw StateError(
                                  'Please choose a smaller image (maximum 5 MB).');
                            }
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
                            await ref
                                .putData(
                                    selectedImageBytes!,
                                    SettableMetadata(
                                      contentType: contentType,
                                      cacheControl: 'public,max-age=86400',
                                    ))
                                .timeout(const Duration(seconds: 45));
                            imageUrl = await ref
                                .getDownloadURL()
                                .timeout(const Duration(seconds: 20));
                          }
                          final data = {
                            'title': t.text.trim(),
                            'category': cat,
                            'date': date.text.trim(),
                            'time': time.text.trim(),
                            'location': loc.text.trim(),
                            'lat': double.tryParse(lat.text.trim()),
                            'lng': double.tryParse(lng.text.trim()),
                            'transportInfo': transport.text.trim(),
                            'parkingInfo': parking.text.trim(),
                            'price': price.text.trim().isEmpty
                                ? 'Free'
                                : price.text.trim(),
                            'description': desc.text.trim(),
                            if (imageUrl != null && imageUrl.isNotEmpty)
                              'imageUrl': imageUrl,
                          };
                          if (id == null) {
                            final event =
                                await Db.createEvent(data, status: 'draft');
                            if (c.mounted) Navigator.pop(c);
                            if (ctx.mounted) {
                              await _afterDraftSaved(
                                  ctx, event.id, t.text.trim());
                            }
                          } else {
                            await Db.updateEvent(id, data);
                            if (c.mounted) Navigator.pop(c);
                          }
                        } on FirebaseException catch (error) {
                          if (c.mounted) {
                            set(() => submitting = false);
                            debugPrint(
                                'Event save failed: plugin=${error.plugin} code=${error.code} message=${error.message}');
                            final message = _firebaseSaveMessage(error);
                            ScaffoldMessenger.of(c).showSnackBar(SnackBar(
                                content:
                                    Text('Could not save event: $message')));
                          }
                        } on TimeoutException {
                          if (c.mounted) {
                            set(() => submitting = false);
                            ScaffoldMessenger.of(c).showSnackBar(const SnackBar(
                                content: Text(
                                    'Image upload timed out. Check your connection and try again.')));
                          }
                        } on StateError catch (error) {
                          if (c.mounted) {
                            set(() => submitting = false);
                            ScaffoldMessenger.of(c).showSnackBar(
                                SnackBar(content: Text(error.message)));
                          }
                        } catch (error) {
                          if (c.mounted) {
                            set(() => submitting = false);
                            ScaffoldMessenger.of(c).showSnackBar(SnackBar(
                                content: Text('Could not save event: $error')));
                          }
                        }
                      },
                child: submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(id == null ? 'Create Draft' : 'Save Changes'),
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
            label: const Text('Start a new event draft'),
          ),
        ),
      );
    }
    if (view == OrganizerView.dashboard) {
      return _OrganizerDashboard(onCreate: () => form(context));
    }
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Events'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Drafts'),
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Changes'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => form(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Event')),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: Db.myEvents(),
          builder: (c, s) {
            if (!s.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = s.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text('No events created yet'));
            }
            const statusGroups = [
              'draft',
              'pending',
              'approved',
              'changes_requested',
              'rejected',
            ];
            return TabBarView(
              children: [
                for (final status in statusGroups)
                  _OrganizerEventList(
                    docs: docs
                        .where((doc) => doc.data()['status'] == status)
                        .toList(),
                    onEdit: (doc) => form(c, id: doc.id, d: doc.data()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrganizerDashboard extends StatelessWidget {
  final VoidCallback onCreate;
  const _OrganizerDashboard({required this.onCreate});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Welcome, $userName')),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Create Event')),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
            final drafts =
                docs.where((doc) => doc.data()['status'] == 'draft').length;
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
                    _DashboardMetric(
                        label: 'Drafts',
                        value: '$drafts',
                        icon: Icons.drafts_outlined),
                  ]),
              const SizedBox(height: 24),
              const Text('Recent Events',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (docs.isEmpty) const Text('No events created yet.'),
              for (final doc in docs.take(5))
                Card(
                    child: ListTile(
                        title: Text(doc['title'] ?? 'Untitled event'),
                        subtitle: Text(
                            '${doc['date'] ?? ''} - ${doc['location'] ?? ''}'),
                        trailing:
                            _StatusBadge(status: doc['status'] ?? 'draft'))),
            ]);
          },
        ),
      );
}

class _OrganizerEventList extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  final void Function(QueryDocumentSnapshot<Map<String, dynamic>> doc) onEdit;
  const _OrganizerEventList({required this.docs, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return const Center(child: Text('No events in this list'));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
      children: [
        for (final d in docs)
          Card(
            child: ListTile(
              title: Text(d['title'] ?? 'Untitled event',
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                  '${d['date'] ?? ''} - ${d['location'] ?? ''}\nStatus: ${_statusText(d.data()['status'] ?? 'draft')}'),
              isThreeLine: true,
              trailing: Wrap(spacing: 2, children: [
                if (d.data()['status'] == 'draft' ||
                    d.data()['status'] == 'changes_requested')
                  IconButton(
                      icon: const Icon(Icons.publish_outlined),
                      tooltip: 'Publish for admin review',
                      onPressed: () => Db.publishEvent(d.id)),
                IconButton(
                    icon: const Icon(Icons.event_note_outlined),
                    tooltip: 'Agenda & facilities',
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => OrganizerScheduleEditorScreen(
                                eventId: d.id,
                                eventTitle: d['title'] ?? 'Untitled event')))),
                IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit event',
                    onPressed: () => onEdit(d)),
                IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete event',
                    onPressed: () => Db.deleteEvent(d.id)),
              ]),
            ),
          ),
      ],
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
            Icon(icon, color: AppColors.primary),
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
    final color = switch (status.trim().toLowerCase()) {
      'approved' => AppColors.success,
      'rejected' => AppColors.error,
      'changes_requested' => AppColors.info,
      'draft' => AppColors.secondaryText,
      _ => AppColors.warning,
    };
    return Chip(
        label: Text(_statusText(status), style: const TextStyle(fontSize: 10)),
        backgroundColor: color.withValues(alpha: .16),
        visualDensity: VisualDensity.compact);
  }
}

String _firebaseSaveMessage(FirebaseException error) {
  if (error.code == 'permission-denied' ||
      error.code == 'unauthorized' ||
      error.code == 'storage/unauthorized') {
    return '${error.plugin}/${error.code}. Firebase rules are blocking this save. Deploy the latest firestore.rules and storage.rules, then try again.';
  }
  return '${error.plugin}/${error.code}: ${error.message ?? 'Unknown Firebase error'}';
}

String _statusText(String status) => switch (status.trim().toLowerCase()) {
      'approved' => 'Published',
      'pending' => 'Pending',
      'draft' => 'Draft',
      'changes_requested' => 'Changes requested',
      'rejected' => 'Rejected',
      _ => status,
    };
