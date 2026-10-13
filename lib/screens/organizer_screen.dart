// // import 'dart:async';
// // import 'dart:typed_data';

// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';

// // import '../services/db.dart';
// // import '../theme/app_theme.dart';
// // import 'organizer_schedule_editor_screen.dart';
// // import 'organizer_facilities_screen.dart';
// // import '../widgets/event_image.dart';
// // import 'event_gallery_screen.dart';

// // enum OrganizerView { dashboard, events, create }

// // class OrganizerScreen extends StatelessWidget {
// //   final OrganizerView view;
// //   const OrganizerScreen({super.key, this.view = OrganizerView.dashboard});

// //   Future<void> _afterDraftSaved(
// //       BuildContext context, String eventId, String title) async {
// //     final action = await showDialog<String>(
// //       context: context,
// //       builder: (dialogContext) => AlertDialog(
// //         title: const Text('Draft saved'),
// //         content: const Text(
// //             'Add agenda items now if this event needs them, or keep it as a draft and publish it later. Facilities can be managed separately at any time.'),
// //         actions: [
// //           TextButton(
// //               onPressed: () => Navigator.pop(dialogContext, 'later'),
// //               child: const Text('Keep as draft')),
// //           FilledButton.icon(
// //               onPressed: () => Navigator.pop(dialogContext, 'details'),
// //               icon: const Icon(Icons.event_note_outlined),
// //               label: const Text('Add details')),
// //         ],
// //       ),
// //     );
// //     if (action == 'details' && context.mounted) {
// //       await Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //               builder: (_) => OrganizerScheduleEditorScreen(
// //                     eventId: eventId,
// //                     eventTitle: title.isEmpty ? 'Untitled event' : title,
// //                   )));
// //     }
// //   }

// //   void form(BuildContext ctx, {String? id, Map<String, dynamic>? d}) {
// //     final t = TextEditingController(text: d?['title']),
// //         date = TextEditingController(text: d?['date']),
// //         time = TextEditingController(text: d?['time']),
// //         loc = TextEditingController(text: d?['location']),
// //         price = TextEditingController(text: d?['price']),
// //         lat = TextEditingController(text: d?['lat']?.toString()),
// //         lng = TextEditingController(text: d?['lng']?.toString()),
// //         transport = TextEditingController(text: d?['transportInfo']),
// //         parking = TextEditingController(text: d?['parkingInfo']),
// //         desc = TextEditingController(text: d?['description']);
// //     String cat = d?['category'] ?? 'Music';
// //     XFile? selectedImage;
// //     Uint8List? selectedImageBytes;
// //     var submitting = false;
// //     showModalBottomSheet(
// //       context: ctx,
// //       isScrollControlled: true,
// //       builder: (_) => StatefulBuilder(
// //         builder: (c, set) => Padding(
// //           padding: EdgeInsets.fromLTRB(
// //               16, 16, 16, MediaQuery.of(c).viewInsets.bottom + 16),
// //           child: SingleChildScrollView(
// //             child: Column(mainAxisSize: MainAxisSize.min, children: [
// //               Text(id == null ? 'Create Event Draft' : 'Edit Event',
// //                   style: const TextStyle(
// //                       fontSize: 18, fontWeight: FontWeight.bold)),
// //               TextField(
// //                   controller: t,
// //                   decoration: const InputDecoration(labelText: 'Event name')),
// //               DropdownButtonFormField<String>(
// //                 initialValue: cat,
// //                 items: ['Music', 'Cultural', 'Food', 'Sports', 'University']
// //                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
// //                     .toList(),
// //                 onChanged: (v) => set(() => cat = v!),
// //               ),
// //               const SizedBox(height: 12),
// //               Align(
// //                   alignment: Alignment.centerLeft,
// //                   child: Text('Event image',
// //                       style: Theme.of(c).textTheme.titleSmall)),
// //               const SizedBox(height: 8),
// //               InkWell(
// //                 borderRadius: BorderRadius.circular(12),
// //                 onTap: submitting
// //                     ? null
// //                     : () async {
// //                         final image = await ImagePicker().pickImage(
// //                           source: ImageSource.gallery,
// //                           imageQuality: 65,
// //                           maxWidth: 1200,
// //                           maxHeight: 900,
// //                         );
// //                         if (image == null) return;
// //                         final bytes = await image.readAsBytes();
// //                         if (c.mounted) {
// //                           set(() {
// //                             selectedImage = image;
// //                             selectedImageBytes = bytes;
// //                           });
// //                         }
// //                       },
// //                 child: Container(
// //                   height: 158,
// //                   width: double.infinity,
// //                   decoration: BoxDecoration(
// //                     color: const Color(0xfff4f6f9),
// //                     borderRadius: BorderRadius.circular(12),
// //                     border: Border.all(color: const Color(0xffd9dde5)),
// //                   ),
// //                   clipBehavior: Clip.antiAlias,
// //                   child: selectedImageBytes != null
// //                       ? Image.memory(selectedImageBytes!, fit: BoxFit.cover)
// //                       : d?['imageUrl'] != null
// //                           ? Image.network(d!['imageUrl'],
// //                               fit: BoxFit.cover,
// //                               errorBuilder: (_, __, ___) => const Center(
// //                                   child: Icon(Icons.broken_image_outlined)))
// //                           : const Column(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Icon(Icons.add_photo_alternate_outlined,
// //                                     size: 38, color: Color(0xff667085)),
// //                                 SizedBox(height: 8),
// //                                 Text('Tap to add event image',
// //                                     style: TextStyle(
// //                                         fontWeight: FontWeight.w700,
// //                                         color: Color(0xff344054))),
// //                                 SizedBox(height: 4),
// //                                 Text('JPG, PNG, or WebP under 5 MB',
// //                                     style: TextStyle(
// //                                         fontSize: 12,
// //                                         color: Color(0xff667085))),
// //                               ],
// //                             ),
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               OutlinedButton.icon(
// //                 onPressed: submitting
// //                     ? null
// //                     : () async {
// //                         final image = await ImagePicker().pickImage(
// //                           source: ImageSource.gallery,
// //                           imageQuality: 65,
// //                           maxWidth: 1200,
// //                           maxHeight: 900,
// //                         );
// //                         if (image == null) return;
// //                         final bytes = await image.readAsBytes();
// //                         if (c.mounted) {
// //                           set(() {
// //                             selectedImage = image;
// //                             selectedImageBytes = bytes;
// //                           });
// //                         }
// //                       },
// //                 icon: const Icon(Icons.photo_library_outlined),
// //                 label: Text(selectedImageBytes == null && d?['imageUrl'] == null
// //                     ? 'Choose image'
// //                     : 'Change image'),
// //               ),
// //               TextField(
// //                   controller: date,
// //                   decoration: const InputDecoration(
// //                       labelText: 'Date (e.g. 2026-10-25)')),
// //               TextField(
// //                   controller: time,
// //                   decoration:
// //                       const InputDecoration(labelText: 'Time (e.g. 9:00 AM)')),
// //               TextField(
// //                   controller: loc,
// //                   decoration:
// //                       const InputDecoration(labelText: 'Venue / Location')),
// //               TextField(
// //                   controller: lat,
// //                   keyboardType:
// //                       const TextInputType.numberWithOptions(decimal: true),
// //                   decoration:
// //                       const InputDecoration(labelText: 'Latitude (optional)')),
// //               TextField(
// //                   controller: lng,
// //                   keyboardType:
// //                       const TextInputType.numberWithOptions(decimal: true),
// //                   decoration:
// //                       const InputDecoration(labelText: 'Longitude (optional)')),
// //               TextField(
// //                   controller: transport,
// //                   decoration: const InputDecoration(
// //                       labelText: 'Transport information (optional)')),
// //               TextField(
// //                   controller: parking,
// //                   decoration: const InputDecoration(
// //                       labelText: 'Parking information (optional)')),
// //               TextField(
// //                   controller: price,
// //                   decoration: const InputDecoration(
// //                       labelText: 'Ticket price (or Free)')),
// //               TextField(
// //                   controller: desc,
// //                   maxLines: 3,
// //                   decoration: const InputDecoration(labelText: 'Description')),
// //               const SizedBox(height: 12),
// //               FilledButton(
// //                 onPressed: submitting
// //                     ? null
// //                     : () async {
// //                         set(() => submitting = true);
// //                         try {
// //                           String? imageUrl = d?['imageUrl']?.toString();
// //                           if (selectedImage != null &&
// //                               selectedImageBytes != null) {
// //                             const maxUploadBytes = 5 * 1024 * 1024;
// //                             if (selectedImageBytes!.length > maxUploadBytes) {
// //                               throw StateError(
// //                                   'Please choose a smaller image (maximum 5 MB).');
// //                             }
// //                             final extension = selectedImage!.name
// //                                 .split('.')
// //                                 .last
// //                                 .toLowerCase();
// //                             imageUrl = await Db.uploadImage(
// //                                     selectedImageBytes!, extension,
// //                                     folder: 'events')
// //                                 .timeout(const Duration(seconds: 45));
// //                           }
// //                           final data = {
// //                             'title': t.text.trim(),
// //                             'category': cat,
// //                             'date': date.text.trim(),
// //                             'time': time.text.trim(),
// //                             'location': loc.text.trim(),
// //                             'lat': double.tryParse(lat.text.trim()),
// //                             'lng': double.tryParse(lng.text.trim()),
// //                             'transportInfo': transport.text.trim(),
// //                             'parkingInfo': parking.text.trim(),
// //                             'price': price.text.trim().isEmpty
// //                                 ? 'Free'
// //                                 : price.text.trim(),
// //                             'description': desc.text.trim(),
// //                             if (imageUrl != null && imageUrl.isNotEmpty)
// //                               'imageUrl': imageUrl,
// //                           };
// //                           if (id == null) {
// //                             final event =
// //                                 await Db.createEvent(data, status: 'draft');
// //                             if (c.mounted) Navigator.pop(c);
// //                             if (ctx.mounted) {
// //                               await _afterDraftSaved(
// //                                   ctx, event.id, t.text.trim());
// //                             }
// //                           } else {
// //                             await Db.updateEvent(id, data);
// //                             if (c.mounted) Navigator.pop(c);
// //                           }
// //                         } on FirebaseException catch (error) {
// //                           if (c.mounted) {
// //                             set(() => submitting = false);
// //                             debugPrint(
// //                                 'Event save failed: plugin=${error.plugin} code=${error.code} message=${error.message}');
// //                             final message = _firebaseSaveMessage(error);
// //                             ScaffoldMessenger.of(c).showSnackBar(SnackBar(
// //                                 content:
// //                                     Text('Could not save event: $message')));
// //                           }
// //                         } on TimeoutException {
// //                           if (c.mounted) {
// //                             set(() => submitting = false);
// //                             ScaffoldMessenger.of(c).showSnackBar(const SnackBar(
// //                                 content: Text(
// //                                     'Image upload timed out. Check your connection and try again.')));
// //                           }
// //                         } on StateError catch (error) {
// //                           if (c.mounted) {
// //                             set(() => submitting = false);
// //                             ScaffoldMessenger.of(c).showSnackBar(
// //                                 SnackBar(content: Text(error.message)));
// //                           }
// //                         } catch (error) {
// //                           if (c.mounted) {
// //                             set(() => submitting = false);
// //                             ScaffoldMessenger.of(c).showSnackBar(SnackBar(
// //                                 content: Text('Could not save event: $error')));
// //                           }
// //                         }
// //                       },
// //                 child: submitting
// //                     ? const SizedBox(
// //                         height: 18,
// //                         width: 18,
// //                         child: CircularProgressIndicator(strokeWidth: 2))
// //                     : Text(id == null ? 'Create Draft' : 'Save Changes'),
// //               )
// //             ]),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     if (view == OrganizerView.create) {
// //       return Scaffold(
// //         appBar: AppBar(title: const Text('Create Event')),
// //         body: Center(
// //           child: FilledButton.icon(
// //             onPressed: () => form(context),
// //             icon: const Icon(Icons.add),
// //             label: const Text('Start a new event draft'),
// //           ),
// //         ),
// //       );
// //     }
// //     if (view == OrganizerView.dashboard) {
// //       return _OrganizerDashboard(onCreate: () => form(context));
// //     }
// //     return DefaultTabController(
// //       length: 5,
// //       child: Scaffold(
// //         appBar: AppBar(
// //           title: const Text('My Events'),
// //           bottom: const TabBar(
// //             isScrollable: true,
// //             tabs: [
// //               Tab(text: 'Drafts'),
// //               Tab(text: 'Pending'),
// //               Tab(text: 'Approved'),
// //               Tab(text: 'Changes'),
// //               Tab(text: 'Rejected'),
// //             ],
// //           ),
// //         ),
// //         floatingActionButton: FloatingActionButton.extended(
// //             onPressed: () => form(context),
// //             icon: const Icon(Icons.add),
// //             label: const Text('Create Event')),
// //         body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
// //           stream: Db.myEvents(),
// //           builder: (c, s) {
// //             if (!s.hasData) {
// //               return const Center(child: CircularProgressIndicator());
// //             }
// //             final docs = s.data!.docs;
// //             if (docs.isEmpty) {
// //               return const Center(child: Text('No events created yet'));
// //             }
// //             const statusGroups = [
// //               'draft',
// //               'pending',
// //               'approved',
// //               'changes_requested',
// //               'rejected',
// //             ];
// //             return TabBarView(
// //               children: [
// //                 for (final status in statusGroups)
// //                   _OrganizerEventList(
// //                     docs: docs
// //                         .where((doc) => doc.data()['status'] == status)
// //                         .toList(),
// //                     onEdit: (doc) => form(c, id: doc.id, d: doc.data()),
// //                   ),
// //               ],
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _OrganizerDashboard extends StatelessWidget {
// //   final VoidCallback onCreate;
// //   const _OrganizerDashboard({required this.onCreate});

// //   @override
// //   Widget build(BuildContext context) => Scaffold(
// //         appBar: AppBar(title: Text('Welcome, $userName')),
// //         floatingActionButton: FloatingActionButton.extended(
// //             onPressed: onCreate,
// //             icon: const Icon(Icons.add),
// //             label: const Text('Create Event')),
// //         body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
// //           stream: Db.myEvents(),
// //           builder: (context, snapshot) {
// //             if (!snapshot.hasData) {
// //               return const Center(child: CircularProgressIndicator());
// //             }
// //             final docs = snapshot.data!.docs;
// //             final published =
// //                 docs.where((doc) => doc.data()['status'] == 'approved').length;
// //             final pending =
// //                 docs.where((doc) => doc.data()['status'] == 'pending').length;
// //             final drafts =
// //                 docs.where((doc) => doc.data()['status'] == 'draft').length;
// //             return ListView(padding: const EdgeInsets.all(16), children: [
// //               const Text('Your event activity at a glance',
// //                   style: TextStyle(color: Colors.grey)),
// //               const SizedBox(height: 16),
// //               GridView.count(
// //                   crossAxisCount: 2,
// //                   shrinkWrap: true,
// //                   physics: const NeverScrollableScrollPhysics(),
// //                   crossAxisSpacing: 10,
// //                   mainAxisSpacing: 10,
// //                   childAspectRatio: 1.7,
// //                   children: [
// //                     _DashboardMetric(
// //                         label: 'Total Events',
// //                         value: '${docs.length}',
// //                         icon: Icons.event),
// //                     _DashboardMetric(
// //                         label: 'Published',
// //                         value: '$published',
// //                         icon: Icons.public),
// //                     _DashboardMetric(
// //                         label: 'Pending Review',
// //                         value: '$pending',
// //                         icon: Icons.hourglass_top),
// //                     _DashboardMetric(
// //                         label: 'Drafts',
// //                         value: '$drafts',
// //                         icon: Icons.drafts_outlined),
// //                   ]),
// //               const SizedBox(height: 24),
// //               const Text('Recent Events',
// //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
// //               const SizedBox(height: 8),
// //               if (docs.isEmpty) const Text('No events created yet.'),
// //               for (final doc in docs.take(5))
// //                 Card(
// //                     child: ListTile(
// //                         leading: EventImage(
// //                             url: doc.data()['imageUrl']?.toString(),
// //                             width: 56,
// //                             height: 56,
// //                             borderRadius:
// //                                 const BorderRadius.all(Radius.circular(6))),
// //                         title: Text(doc['title'] ?? 'Untitled event'),
// //                         subtitle: Text(
// //                             '${doc['date'] ?? ''} - ${doc['location'] ?? ''}'),
// //                         trailing:
// //                             _StatusBadge(status: doc['status'] ?? 'draft'))),
// //             ]);
// //           },
// //         ),
// //       );
// // }

// // class _OrganizerEventList extends StatelessWidget {
// //   final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
// //   final void Function(QueryDocumentSnapshot<Map<String, dynamic>> doc) onEdit;
// //   const _OrganizerEventList({required this.docs, required this.onEdit});

// //   @override
// //   Widget build(BuildContext context) {
// //     if (docs.isEmpty) {
// //       return const Center(child: Text('No events in this list'));
// //     }
// //     return ListView(
// //       padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
// //       children: [
// //         for (final d in docs)
// //           Card(
// //             child: ListTile(
// //               leading: EventImage(
// //                   url: d.data()['imageUrl']?.toString(),
// //                   width: 56,
// //                   height: 56,
// //                   borderRadius: const BorderRadius.all(Radius.circular(6))),
// //               title: Text(d['title'] ?? 'Untitled event',
// //                   maxLines: 2, overflow: TextOverflow.ellipsis),
// //               subtitle: Text(
// //                   '${d['date'] ?? ''} - ${d['location'] ?? ''}\nStatus: ${_statusText(d.data()['status'] ?? 'draft')}'),
// //               isThreeLine: true,
// //               trailing: Wrap(spacing: 2, children: [
// //                 if (d.data()['status'] == 'draft' ||
// //                     d.data()['status'] == 'changes_requested')
// //                   IconButton(
// //                       icon: const Icon(Icons.publish_outlined),
// //                       tooltip: 'Publish for admin review',
// //                       onPressed: () => Db.publishEvent(d.id)),
// //                 if (d.data()['status'] == 'draft' ||
// //                     d.data()['status'] == 'changes_requested')
// //                   IconButton(
// //                       icon: const Icon(Icons.event_note_outlined),
// //                       tooltip: 'Agenda',
// //                       onPressed: () => Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                               builder: (_) => OrganizerScheduleEditorScreen(
// //                                   eventId: d.id,
// //                                   eventTitle:
// //                                       d['title'] ?? 'Untitled event')))),
// //                 IconButton(
// //                     icon: const Icon(Icons.business_outlined),
// //                     tooltip: 'Manage Facilities',
// //                     onPressed: () => Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                             builder: (_) => OrganizerFacilitiesScreen(
// //                                 eventId: d.id,
// //                                 eventTitle: d['title'] ?? 'Untitled event')))),
// //                 IconButton(
// //                     icon: const Icon(Icons.photo_library_outlined),
// //                     tooltip: 'Event gallery',
// //                     onPressed: () => Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                             builder: (_) => EventGalleryScreen(
// //                                 eventId: d.id,
// //                                 eventTitle: d['title'] ?? 'Untitled event',
// //                                 mode: GalleryMode.organizer)))),
// //                 IconButton(
// //                     icon: const Icon(Icons.edit_outlined),
// //                     tooltip: 'Edit event',
// //                     onPressed: () => onEdit(d)),
// //                 IconButton(
// //                     icon: const Icon(Icons.delete_outline),
// //                     tooltip: 'Delete event',
// //                     onPressed: () => Db.deleteEvent(d.id)),
// //               ]),
// //             ),
// //           ),
// //       ],
// //     );
// //   }
// // }

// // class _DashboardMetric extends StatelessWidget {
// //   final String label;
// //   final String value;
// //   final IconData icon;
// //   const _DashboardMetric(
// //       {required this.label, required this.value, required this.icon});

// //   @override
// //   Widget build(BuildContext context) => Card(
// //         child: Padding(
// //           padding: const EdgeInsets.all(12),
// //           child: Row(children: [
// //             Icon(icon, color: AppColors.primary),
// //             const SizedBox(width: 8),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Text(value,
// //                       style: const TextStyle(
// //                           fontSize: 20, fontWeight: FontWeight.w800)),
// //                   Text(label,
// //                       maxLines: 1,
// //                       overflow: TextOverflow.ellipsis,
// //                       style: const TextStyle(fontSize: 11, color: Colors.grey)),
// //                 ],
// //               ),
// //             ),
// //           ]),
// //         ),
// //       );
// // }

// // class _StatusBadge extends StatelessWidget {
// //   final String status;
// //   const _StatusBadge({required this.status});
// //   @override
// //   Widget build(BuildContext context) {
// //     final color = switch (status.trim().toLowerCase()) {
// //       'approved' => AppColors.success,
// //       'rejected' => AppColors.error,
// //       'changes_requested' => AppColors.info,
// //       'draft' => AppColors.secondaryText,
// //       _ => AppColors.warning,
// //     };
// //     return Chip(
// //         label: Text(_statusText(status), style: const TextStyle(fontSize: 10)),
// //         backgroundColor: color.withValues(alpha: .16),
// //         visualDensity: VisualDensity.compact);
// //   }
// // }

// // String _firebaseSaveMessage(FirebaseException error) {
// //   if (error.code == 'permission-denied' ||
// //       error.code == 'unauthorized' ||
// //       error.code == 'storage/unauthorized') {
// //     return '${error.plugin}/${error.code}. Firebase rules are blocking this save. Deploy the latest firestore.rules and storage.rules, then try again.';
// //   }
// //   return '${error.plugin}/${error.code}: ${error.message ?? 'Unknown Firebase error'}';
// // }

// // String _statusText(String status) => switch (status.trim().toLowerCase()) {
// //       'approved' => 'Published',
// //       'pending' => 'Pending',
// //       'draft' => 'Draft',
// //       'changes_requested' => 'Changes requested',
// //       'rejected' => 'Rejected',
// //       _ => status,
// //     };
// import 'dart:async';
// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// import '../services/db.dart';
// import '../theme/app_theme.dart';
// import 'organizer_schedule_editor_screen.dart';
// import 'organizer_facilities_screen.dart';
// import '../widgets/event_image.dart';
// import 'event_gallery_screen.dart';

// enum OrganizerView { dashboard, events, create }

// class OrganizerScreen extends StatelessWidget {
//   final OrganizerView view;
//   const OrganizerScreen({super.key, this.view = OrganizerView.dashboard});

//   Future<void> _afterDraftSaved(
//       BuildContext context, String eventId, String title) async {
//     final action = await showDialog<String>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         backgroundColor: AppColors.surface,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text('Draft saved', style: TextStyle(fontWeight: FontWeight.w700)),
//         content: const Text(
//             'Add agenda items now if this event needs them, or keep it as a draft and publish it later. Facilities can be managed separately at any time.'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(dialogContext, 'later'),
//               child: const Text('Keep as draft')),
//           FilledButton.icon(
//               onPressed: () => Navigator.pop(dialogContext, 'details'),
//               icon: const Icon(Icons.event_note_outlined),
//               label: const Text('Add details')),
//         ],
//       ),
//     );
//     if (action == 'details' && context.mounted) {
//       await Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (_) => OrganizerScheduleEditorScreen(
//                     eventId: eventId,
//                     eventTitle: title.isEmpty ? 'Untitled event' : title,
//                   )));
//     }
//   }

//   void form(BuildContext ctx, {String? id, Map<String, dynamic>? d}) {
//     final t = TextEditingController(text: d?['title']),
//         date = TextEditingController(text: d?['date']),
//         time = TextEditingController(text: d?['time']),
//         loc = TextEditingController(text: d?['location']),
//         price = TextEditingController(text: d?['price']),
//         lat = TextEditingController(text: d?['lat']?.toString()),
//         lng = TextEditingController(text: d?['lng']?.toString()),
//         transport = TextEditingController(text: d?['transportInfo']),
//         parking = TextEditingController(text: d?['parkingInfo']),
//         desc = TextEditingController(text: d?['description']);
//     String cat = d?['category'] ?? 'Music';
//     XFile? selectedImage;
//     Uint8List? selectedImageBytes;
//     var submitting = false;
//     showModalBottomSheet(
//       context: ctx,
//       isScrollControlled: true,
//       backgroundColor: AppColors.surface,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
//       builder: (_) => StatefulBuilder(
//         builder: (c, set) => Padding(
//           padding: EdgeInsets.fromLTRB(
//               20, 18, 20, MediaQuery.of(c).viewInsets.bottom + 24),
//           child: SingleChildScrollView(
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               const _FormGrabber(),
//               const SizedBox(height: 14),
//               Row(children: [
//                 Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.edit_calendar_outlined, color: AppColors.primary)),
//                 const SizedBox(width: 12),
//                 Expanded(child: Text(id == null ? 'Create Event Draft' : 'Edit Event', style: Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
//               ]),
//               const SizedBox(height: 8),
//               const Align(alignment: Alignment.centerLeft, child: Text('Fill in the event details below', style: TextStyle(fontSize: 12, color: AppColors.secondaryText))),
//               const SizedBox(height: 20),
//               TextField(
//                   controller: t,
//                   decoration: const InputDecoration(labelText: 'Event name', prefixIcon: Icon(Icons.celebration_outlined, color: AppColors.primary))),
//               DropdownButtonFormField<String>(
//                 initialValue: cat,
//                 decoration: const InputDecoration(labelText: 'Event category', prefixIcon: Icon(Icons.category_outlined, color: AppColors.primary)),
//                 items: ['Music', 'Cultural', 'Food', 'Sports', 'University']
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//                 onChanged: (v) => set(() => cat = v!),
//               ),
//               const SizedBox(height: 19),
//               Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text('Event image',
//                       style: Theme.of(c).textTheme.titleSmall)),
//               const SizedBox(height: 8),
//               InkWell(
//                 borderRadius: BorderRadius.circular(12),
//                 onTap: submitting
//                     ? null
//                     : () async {
//                         final image = await ImagePicker().pickImage(
//                           source: ImageSource.gallery,
//                           imageQuality: 65,
//                           maxWidth: 1200,
//                           maxHeight: 900,
//                         );
//                         if (image == null) return;
//                         final bytes = await image.readAsBytes();
//                         if (c.mounted) {
//                           set(() {
//                             selectedImage = image;
//                             selectedImageBytes = bytes;
//                           });
//                         }
//                       },
//                 child: Container(
//                   height: 158,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: AppColors.background,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: AppColors.border),
//                   ),
//                   clipBehavior: Clip.antiAlias,
//                   child: selectedImageBytes != null
//                       ? Image.memory(selectedImageBytes!, fit: BoxFit.cover)
//                       : d?['imageUrl'] != null
//                           ? Image.network(d!['imageUrl'],
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) => const Center(
//                                   child: Icon(Icons.broken_image_outlined)))
//                           : const Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.add_photo_alternate_outlined,
//                                     size: 38, color: AppColors.secondaryText),
//                                 SizedBox(height: 8),
//                                 Text('Tap to add event image',
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.w700,
//                                         color: AppColors.primaryDark)),
//                                 SizedBox(height: 4),
//                                 Text('JPG, PNG, or WebP under 5 MB',
//                                     style: TextStyle(
//                                         fontSize: 12,
//                                         color: AppColors.secondaryText)),
//                               ],
//                             ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               OutlinedButton.icon(
//                 onPressed: submitting
//                     ? null
//                     : () async {
//                         final image = await ImagePicker().pickImage(
//                           source: ImageSource.gallery,
//                           imageQuality: 65,
//                           maxWidth: 1200,
//                           maxHeight: 900,
//                         );
//                         if (image == null) return;
//                         final bytes = await image.readAsBytes();
//                         if (c.mounted) {
//                           set(() {
//                             selectedImage = image;
//                             selectedImageBytes = bytes;
//                           });
//                         }
//                       },
//                 icon: const Icon(Icons.photo_library_outlined),
//                 label: Text(selectedImageBytes == null && d?['imageUrl'] == null
//                     ? 'Choose image'
//                     : 'Change image'),
//               ),
//               TextField(
//                   controller: date,
//                   decoration: const InputDecoration(
//                       labelText: 'Date (e.g. 2026-10-25)', prefixIcon: Icon(Icons.calendar_month_outlined, color: AppColors.primary))),
//               TextField(
//                   controller: time,
//                   decoration:
//                       const InputDecoration(labelText: 'Time (e.g. 9:00 AM)', prefixIcon: Icon(Icons.schedule_outlined, color: AppColors.primary))),
//               TextField(
//                   controller: loc,
//                   decoration:
//                       const InputDecoration(labelText: 'Venue / Location', prefixIcon: Icon(Icons.place_outlined, color: AppColors.primary))),
//               TextField(
//                   controller: lat,
//                   keyboardType:
//                       const TextInputType.numberWithOptions(decimal: true),
//                   decoration:
//                       const InputDecoration(labelText: 'Latitude (optional)', prefixIcon: Icon(Icons.my_location_outlined, color: AppColors.primary))),
//               TextField(
//                   controller: lng,
//                   keyboardType:
//                       const TextInputType.numberWithOptions(decimal: true),
//                   decoration:
//                       const InputDecoration(labelText: 'Longitude (optional)', prefixIcon: Icon(Icons.explore_outlined, color: AppColors.primary))),
//               TextField(
//                   controller: transport,
//                   decoration: const InputDecoration(
//                       labelText: 'Transport information (optional)', prefixIcon: Icon(Icons.directions_bus_outlined, color: AppColors.primary))),
//               TextField(
//                   controller: parking,
//                   decoration: const InputDecoration(
//                       labelText: 'Parking information (optional)', prefixIcon: Icon(Icons.local_parking_outlined, color: AppColors.primary))),
//               TextField(
//                   controller: price,
//                   decoration: const InputDecoration(
//                       labelText: 'Ticket price (or Free)', prefixIcon: Icon(Icons.sell_outlined, color: AppColors.primary))),
//               TextField(
//                   controller: desc,
//                   maxLines: 3,
//                   decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.notes_outlined, color: AppColors.primary))),
//               const SizedBox(height: 20),
//               SizedBox(width: double.infinity, child: FilledButton(
//                 onPressed: submitting
//                     ? null
//                     : () async {
//                         set(() => submitting = true);
//                         try {
//                           String? imageUrl = d?['imageUrl']?.toString();
//                           if (selectedImage != null &&
//                               selectedImageBytes != null) {
//                             const maxUploadBytes = 5 * 1024 * 1024;
//                             if (selectedImageBytes!.length > maxUploadBytes) {
//                               throw StateError(
//                                   'Please choose a smaller image (maximum 5 MB).');
//                             }
//                             final extension = selectedImage!.name
//                                 .split('.')
//                                 .last
//                                 .toLowerCase();
//                             imageUrl = await Db.uploadImage(
//                                     selectedImageBytes!, extension,
//                                     folder: 'events')
//                                 .timeout(const Duration(seconds: 45));
//                           }
//                           final data = {
//                             'title': t.text.trim(),
//                             'category': cat,
//                             'date': date.text.trim(),
//                             'time': time.text.trim(),
//                             'location': loc.text.trim(),
//                             'lat': double.tryParse(lat.text.trim()),
//                             'lng': double.tryParse(lng.text.trim()),
//                             'transportInfo': transport.text.trim(),
//                             'parkingInfo': parking.text.trim(),
//                             'price': price.text.trim().isEmpty
//                                 ? 'Free'
//                                 : price.text.trim(),
//                             'description': desc.text.trim(),
//                             if (imageUrl != null && imageUrl.isNotEmpty)
//                               'imageUrl': imageUrl,
//                           };
//                           if (id == null) {
//                             final event =
//                                 await Db.createEvent(data, status: 'draft');
//                             if (c.mounted) Navigator.pop(c);
//                             if (ctx.mounted) {
//                               await _afterDraftSaved(
//                                   ctx, event.id, t.text.trim());
//                             }
//                           } else {
//                             await Db.updateEvent(id, data);
//                             if (c.mounted) Navigator.pop(c);
//                           }
//                         } on FirebaseException catch (error) {
//                           if (c.mounted) {
//                             set(() => submitting = false);
//                             debugPrint(
//                                 'Event save failed: plugin=${error.plugin} code=${error.code} message=${error.message}');
//                             final message = _firebaseSaveMessage(error);
//                             ScaffoldMessenger.of(c).showSnackBar(SnackBar(
//                                 content:
//                                     Text('Could not save event: $message')));
//                           }
//                         } on TimeoutException {
//                           if (c.mounted) {
//                             set(() => submitting = false);
//                             ScaffoldMessenger.of(c).showSnackBar(const SnackBar(
//                                 content: Text(
//                                     'Image upload timed out. Check your connection and try again.')));
//                           }
//                         } on StateError catch (error) {
//                           if (c.mounted) {
//                             set(() => submitting = false);
//                             ScaffoldMessenger.of(c).showSnackBar(
//                                 SnackBar(content: Text(error.message)));
//                           }
//                         } catch (error) {
//                           if (c.mounted) {
//                             set(() => submitting = false);
//                             ScaffoldMessenger.of(c).showSnackBar(SnackBar(
//                                 content: Text('Could not save event: $error')));
//                           }
//                         }
//                       },
//                 child: submitting
//                     ? const SizedBox(
//                         height: 18,
//                         width: 18,
//                         child: CircularProgressIndicator(strokeWidth: 2))
//                     : Text(id == null ? 'Create Draft' : 'Save Changes'),
//               ))
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (view == OrganizerView.create) {
//       return Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(title: const Text('Create Event')),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(22),
//             child: _Panel(
//               child: Column(mainAxisSize: MainAxisSize.min, children: [
//                 Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: .12)), child: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 44)),
//                 const SizedBox(height: 16),
//                 Text('Create something memorable', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
//                 const SizedBox(height: 8),
//                 const Text('Start with a draft, then add your agenda and facilities.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.secondaryText, height: 1.5)),
//                 const SizedBox(height: 22),
//                 SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => form(context), icon: const Icon(Icons.add), label: const Text('Start a new event draft'))),
//               ]),
//             ),
//           ),
//         ),
//       );
//     }
//     if (view == OrganizerView.dashboard) {
//       return _OrganizerDashboard(onCreate: () => form(context));
//     }
//     return DefaultTabController(
//       length: 5,
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(
//           title: const Text('My Events'),
//           backgroundColor: AppColors.surface,
//           bottom: TabBar(
//             isScrollable: true,
//             tabAlignment: TabAlignment.start,
//             indicatorColor: AppColors.primary,
//             labelColor: AppColors.primaryDark,
//             unselectedLabelColor: AppColors.secondaryText,
//             tabs: const [
//               Tab(text: 'Drafts'),
//               Tab(text: 'Pending'),
//               Tab(text: 'Approved'),
//               Tab(text: 'Changes'),
//               Tab(text: 'Rejected'),
//             ],
//           ),
//         ),
//         floatingActionButton: FloatingActionButton.extended(
//           backgroundColor: AppColors.primary,
//           foregroundColor: AppColors.primaryDark,
//           onPressed: () => form(context),
//           icon: const Icon(Icons.add),
//           label: const Text('Create Event'),
//         ),
//         body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//           stream: Db.myEvents(),
//           builder: (c, s) {
//             if (!s.hasData) return const Center(child: CircularProgressIndicator());
//             final docs = s.data!.docs;
//             if (docs.isEmpty) {
//               return const _EmptyOrganizerState(message: 'No events created yet');
//             }
//             const statusGroups = [
//               'draft', 'pending', 'approved', 'changes_requested', 'rejected',
//             ];
//             return TabBarView(
//               children: [
//                 for (final status in statusGroups)
//                   _OrganizerEventList(
//                     docs: docs.where((doc) => doc.data()['status'] == status).toList(),
//                     onEdit: (doc) => form(c, id: doc.id, d: doc.data()),
//                   ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class _FormGrabber extends StatelessWidget {
//   const _FormGrabber();
//   @override
//   Widget build(BuildContext context) => Center(child: Container(width: 42, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(6))));
// }

// class _OrganizerDashboard extends StatelessWidget {
//   final VoidCallback onCreate;
//   const _OrganizerDashboard({required this.onCreate});

//   @override
//   Widget build(BuildContext context) => Scaffold(
//     backgroundColor: AppColors.background,
//     appBar: AppBar(title: const Text('Organizer Dashboard'), backgroundColor: AppColors.surface),
//     floatingActionButton: FloatingActionButton.extended(
//       backgroundColor: AppColors.primary,
//       foregroundColor: AppColors.primaryDark,
//       onPressed: onCreate,
//       icon: const Icon(Icons.add),
//       label: const Text('Create Event'),
//     ),
//     body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//       stream: Db.myEvents(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//         final docs = snapshot.data!.docs;
//         final published = docs.where((doc) => doc.data()['status'] == 'approved').length;
//         final pending = docs.where((doc) => doc.data()['status'] == 'pending').length;
//         final drafts = docs.where((doc) => doc.data()['status'] == 'draft').length;
//         return ListView(
//           physics: const BouncingScrollPhysics(),
//           padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
//           children: [
//             const _Eyebrow(label: 'ORGANIZER WORKSPACE'),
//             const SizedBox(height: 8),
//             Text('Welcome, $userName', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 25, fontWeight: FontWeight.w800)),
//             const SizedBox(height: 6),
//             const Text('Your event activity at a glance', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
//             const SizedBox(height: 18),
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFE6B84F)]),
//                 borderRadius: BorderRadius.circular(22),
//               ),
//               child: Row(children: [
//                 const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Text('CREATE & INSPIRE', style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
//                   SizedBox(height: 8),
//                   Text('Bring your next event to life', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
//                   SizedBox(height: 6),
//                   Text('Plan, publish and manage all your experiences.', style: TextStyle(fontSize: 11, height: 1.5, color: AppColors.primaryDark)),
//                 ])),
//                 const SizedBox(width: 12),
//                 Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .28)), child: const Icon(Icons.event_available_rounded, size: 33, color: AppColors.primaryDark)),
//               ]),
//             ),
//             const SizedBox(height: 19),
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisSpacing: 11,
//               mainAxisSpacing: 11,
//               mainAxisExtent: 108,
//               children: [
//                 _DashboardMetric(label: 'Total Events', value: '${docs.length}', icon: Icons.event_outlined, color: AppColors.primary),
//                 _DashboardMetric(label: 'Published', value: '$published', icon: Icons.public_rounded, color: AppColors.success),
//                 _DashboardMetric(label: 'Pending Review', value: '$pending', icon: Icons.hourglass_top_rounded, color: AppColors.warning),
//                 _DashboardMetric(label: 'Drafts', value: '$drafts', icon: Icons.drafts_outlined, color: AppColors.info),
//               ],
//             ),
//             const SizedBox(height: 26),
//             const _SectionHeading(title: 'Recent Events', subtitle: 'Your latest event submissions', icon: Icons.history_rounded),
//             const SizedBox(height: 13),
//             if (docs.isEmpty) const _EmptyOrganizerState(message: 'No events created yet.'),
//             for (final doc in docs.take(5))
//               Padding(padding: const EdgeInsets.only(bottom: 12), child: _EventCard(data: doc.data(), status: doc.data()['status']?.toString() ?? 'draft')),
//           ],
//         );
//       },
//     ),
//   );
// }

// class _OrganizerEventList extends StatelessWidget {
//   final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
//   final void Function(QueryDocumentSnapshot<Map<String, dynamic>> doc) onEdit;
//   const _OrganizerEventList({required this.docs, required this.onEdit});

//   @override
//   Widget build(BuildContext context) {
//     if (docs.isEmpty) return const _EmptyOrganizerState(message: 'No events in this list');
//     return ListView(
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
//       children: [
//         _SectionHeading(title: 'Event Submissions', subtitle: '${docs.length} events in this category', icon: Icons.event_note_outlined),
//         const SizedBox(height: 13),
//         for (final d in docs)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 13),
//             child: _Panel(
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 _EventCard(data: d.data(), status: d.data()['status']?.toString() ?? 'draft', embedded: true),
//                 const SizedBox(height: 12),
//                 const Divider(color: AppColors.border, height: 1),
//                 const SizedBox(height: 9),
//                 // Original action availability and navigation retained.
//                 Wrap(
//                   alignment: WrapAlignment.end,
//                   spacing: 2,
//                   runSpacing: 3,
//                   children: [
//                     if (d.data()['status'] == 'draft' || d.data()['status'] == 'changes_requested')
//                       IconButton(icon: const Icon(Icons.publish_outlined, color: AppColors.success), tooltip: 'Publish for admin review', onPressed: () => Db.publishEvent(d.id)),
//                     if (d.data()['status'] == 'draft' || d.data()['status'] == 'changes_requested')
//                       IconButton(icon: const Icon(Icons.event_note_outlined, color: AppColors.primary), tooltip: 'Agenda', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrganizerScheduleEditorScreen(eventId: d.id, eventTitle: d['title'] ?? 'Untitled event')))),
//                     IconButton(icon: const Icon(Icons.business_outlined, color: AppColors.primary), tooltip: 'Manage Facilities', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrganizerFacilitiesScreen(eventId: d.id, eventTitle: d['title'] ?? 'Untitled event')))),
//                     IconButton(icon: const Icon(Icons.photo_library_outlined, color: AppColors.primary), tooltip: 'Event gallery', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventGalleryScreen(eventId: d.id, eventTitle: d['title'] ?? 'Untitled event', mode: GalleryMode.organizer)))),
//                     IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.primaryDark), tooltip: 'Edit event', onPressed: () => onEdit(d)),
//                     IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), tooltip: 'Delete event', onPressed: () => Db.deleteEvent(d.id)),
//                   ],
//                 ),
//               ]),
//             ),
//           ),
//       ],
//     );
//   }
// }

// class _EventCard extends StatelessWidget {
//   final Map<String, dynamic> data;
//   final String status;
//   final bool embedded;
//   const _EventCard({required this.data, required this.status, this.embedded = false});

//   @override
//   Widget build(BuildContext context) {
//     final contents = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       EventImage(url: data['imageUrl']?.toString(), width: 86, height: 99, borderRadius: BorderRadius.circular(12)),
//       const SizedBox(width: 12),
//       Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         _StatusBadge(status: status),
//         const SizedBox(height: 5),
//         Text(data['title']?.toString() ?? 'Untitled event', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
//         const SizedBox(height: 6),
//         _MetaRow(icon: Icons.calendar_today_outlined, text: data['date']?.toString() ?? ''),
//         const SizedBox(height: 5),
//         _MetaRow(icon: Icons.location_on_outlined, text: data['location']?.toString() ?? ''),
//       ])),
//     ]);
//     return embedded ? contents : _Panel(child: contents);
//   }
// }

// class _Panel extends StatelessWidget {
//   final Widget child;
//   const _Panel({required this.child});
//   @override
//   Widget build(BuildContext context) => Container(
//     width: double.infinity,
//     padding: const EdgeInsets.all(15),
//     decoration: BoxDecoration(
//       color: AppColors.surface,
//       borderRadius: BorderRadius.circular(18),
//       border: Border.all(color: AppColors.border),
//       boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: .035), blurRadius: 15, offset: const Offset(0, 5))],
//     ),
//     child: child,
//   );
// }

// class _MetaRow extends StatelessWidget {
//   final IconData icon;
//   final String text;
//   const _MetaRow({required this.icon, required this.text});
//   @override
//   Widget build(BuildContext context) => Row(children: [
//     Icon(icon, size: 13, color: AppColors.primary),
//     const SizedBox(width: 5),
//     Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.secondaryText, fontSize: 10))),
//   ]);
// }

// class _SectionHeading extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   const _SectionHeading({required this.title, required this.subtitle, required this.icon});
//   @override
//   Widget build(BuildContext context) => Row(children: [
//     Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary, size: 21)),
//     const SizedBox(width: 11),
//     Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
//       const SizedBox(height: 3),
//       Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
//     ])),
//   ]);
// }

// class _Eyebrow extends StatelessWidget {
//   final String label;
//   const _Eyebrow({required this.label});
//   @override
//   Widget build(BuildContext context) => Row(children: [
//     Container(width: 22, height: 3, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6))),
//     const SizedBox(width: 8),
//     Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.primary)),
//   ]);
// }

// class _EmptyOrganizerState extends StatelessWidget {
//   final String message;
//   const _EmptyOrganizerState({required this.message});
//   @override
//   Widget build(BuildContext context) => Center(child: Padding(
//     padding: const EdgeInsets.all(24),
//     child: Column(mainAxisSize: MainAxisSize.min, children: [
//       Container(padding: const EdgeInsets.all(23), decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: .11)), child: const Icon(Icons.event_busy_outlined, size: 40, color: AppColors.primary)),
//       const SizedBox(height: 15),
//       Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
//       const SizedBox(height: 5),
//       const Text('Your events will appear here.', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
//     ]),
//   ));
// }

// class _DashboardMetric extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color color;
//   const _DashboardMetric({required this.label, required this.value, required this.icon, required this.color});

//   @override
//   Widget build(BuildContext context) => _Panel(
//     child: Row(children: [
//       Container(width: 37, height: 37, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 20)),
//       const SizedBox(width: 10),
//       Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
//         Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
//       ])),
//     ]),
//   );
// }

// class _StatusBadge extends StatelessWidget {
//   final String status;
//   const _StatusBadge({required this.status});

//   @override
//   Widget build(BuildContext context) {
//     final color = switch (status.trim().toLowerCase()) {
//       'approved' => AppColors.success,
//       'rejected' => AppColors.error,
//       'changes_requested' => AppColors.info,
//       'draft' => AppColors.secondaryText,
//       _ => AppColors.warning,
//     };
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
//       decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)),
//       child: Text(_statusText(status), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
//     );
//   }
// }

// String _firebaseSaveMessage(FirebaseException error) {
//   if (error.code == 'permission-denied' ||
//       error.code == 'unauthorized' ||
//       error.code == 'storage/unauthorized') {
//     return '${error.plugin}/${error.code}. Firebase rules are blocking this save. Deploy the latest firestore.rules and storage.rules, then try again.';
//   }
//   return '${error.plugin}/${error.code}: ${error.message ?? 'Unknown Firebase error'}';
// }

// String _statusText(String status) => switch (status.trim().toLowerCase()) {
//       'approved' => 'Published',
//       'pending' => 'Pending',
//       'draft' => 'Draft',
//       'changes_requested' => 'Changes requested',
//       'rejected' => 'Rejected',
//       _ => status,
//     };


import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/db.dart';
import '../theme/app_theme.dart';
import 'organizer_schedule_editor_screen.dart';
import 'organizer_facilities_screen.dart';
import '../widgets/event_image.dart';
import 'event_gallery_screen.dart';

enum OrganizerView { dashboard, events, create }

// UI-only helpers. Firestore still stores date and time as strings.
DateTime? _parseEventDate(String raw) {
  final parsed = DateTime.tryParse(raw.trim());
  return parsed == null ? null : DateTime(parsed.year, parsed.month, parsed.day);
}

String _formatEventDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

TimeOfDay? _parseEventTime(String raw) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$', caseSensitive: false)
      .firstMatch(raw.trim());
  if (match == null) return null;

  final hour = int.tryParse(match.group(1)!);
  final minute = int.tryParse(match.group(2)!);
  if (hour == null || minute == null || minute > 59) return null;

  final period = match.group(3)?.toUpperCase();
  if (period == null) {
    return hour <= 23 ? TimeOfDay(hour: hour, minute: minute) : null;
  }
  if (hour < 1 || hour > 12) return null;
  final hour24 = (hour % 12) + (period == 'PM' ? 12 : 0);
  return TimeOfDay(hour: hour24, minute: minute);
}

String _formatEventTime(TimeOfDay value) {
  final hour12 = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour12:$minute $period';
}

class OrganizerScreen extends StatelessWidget {
  final OrganizerView view;
  const OrganizerScreen({super.key, this.view = OrganizerView.dashboard});

  Future<void> _afterDraftSaved(
      BuildContext context, String eventId, String title) async {
    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Draft saved', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Add agenda items now if this event needs them, or keep it as a draft and publish it later. Facilities can be managed separately at any time.'),
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (_) => StatefulBuilder(
        builder: (c, set) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 18, 20, MediaQuery.of(c).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const _FormGrabber(),
              const SizedBox(height: 14),
              Row(children: [
                Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.edit_calendar_outlined, color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: Text(id == null ? 'Create Event Draft' : 'Edit Event', style: Theme.of(c).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
              ]),
              const SizedBox(height: 8),
              const Align(alignment: Alignment.centerLeft, child: Text('Fill in the event details below', style: TextStyle(fontSize: 12, color: AppColors.secondaryText))),
              const SizedBox(height: 20),
              TextField(
                  controller: t,
                  decoration: const InputDecoration(labelText: 'Event name', prefixIcon: Icon(Icons.celebration_outlined, color: AppColors.primary))),
              DropdownButtonFormField<String>(
                initialValue: cat,
                decoration: const InputDecoration(labelText: 'Event category', prefixIcon: Icon(Icons.category_outlined, color: AppColors.primary)),
                items: ['Music', 'Cultural', 'Food', 'Sports', 'University']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => set(() => cat = v!),
              ),
              const SizedBox(height: 19),
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
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
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
                                    size: 38, color: AppColors.secondaryText),
                                SizedBox(height: 8),
                                Text('Tap to add event image',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark)),
                                SizedBox(height: 4),
                                Text('JPG, PNG, or WebP under 5 MB',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryText)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 18),
              // ACTUAL TAP-TO-OPEN DATE & TIME PICKERS (no typing).
              _DateTimePickerTile(
                label: 'Event Date',
                selectedValue: date.text.trim(),
                placeholder: 'Choose event date',
                helper: 'Tap to open calendar',
                icon: Icons.calendar_month_rounded,
                enabled: !submitting,
                onTap: () async {
                  FocusScope.of(c).unfocus();
                  final storedDate = _parseEventDate(date.text);
                  final minDate = DateTime(1900);
                  final maxDate = DateTime(2100, 12, 31);
                  final initialDate = storedDate != null &&
                          !storedDate.isBefore(minDate) &&
                          !storedDate.isAfter(maxDate)
                      ? storedDate
                      : DateTime.now();
                  final pickedDate = await showDatePicker(
                    context: c,
                    initialDate: initialDate,
                    firstDate: minDate,
                    lastDate: maxDate,
                    helpText: 'SELECT EVENT DATE',
                    builder: (pickerContext, child) => Theme(
                      data: Theme.of(pickerContext).copyWith(
                        colorScheme:
                            Theme.of(pickerContext).colorScheme.copyWith(
                                  primary: AppColors.primary,
                                  onPrimary: AppColors.primaryDark,
                                ),
                      ),
                      child: child!,
                    ),
                  );
                  if (pickedDate != null && c.mounted) {
                    set(() {
                      date.text = _formatEventDate(pickedDate);
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              _DateTimePickerTile(
                label: 'Event Time',
                selectedValue: time.text.trim(),
                placeholder: 'Choose event time',
                helper: 'Tap to open time picker',
                icon: Icons.access_time_filled_rounded,
                enabled: !submitting,
                onTap: () async {
                  FocusScope.of(c).unfocus();
                  final pickedTime = await showTimePicker(
                    context: c,
                    initialTime:
                        _parseEventTime(time.text) ?? TimeOfDay.now(),
                    helpText: 'SELECT EVENT TIME',
                    builder: (pickerContext, child) => Theme(
                      data: Theme.of(pickerContext).copyWith(
                        timePickerTheme: const TimePickerThemeData(
                          backgroundColor: AppColors.surface,
                        ),
                        colorScheme:
                            Theme.of(pickerContext).colorScheme.copyWith(
                                  primary: AppColors.primary,
                                  onPrimary: AppColors.primaryDark,
                                ),
                      ),
                      child: child!,
                    ),
                  );
                  if (pickedTime != null && c.mounted) {
                    set(() {
                      time.text = _formatEventTime(pickedTime);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                  controller: loc,
                  decoration:
                      const InputDecoration(labelText: 'Venue / Location', prefixIcon: Icon(Icons.place_outlined, color: AppColors.primary))),
              TextField(
                  controller: lat,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Latitude (optional)', prefixIcon: Icon(Icons.my_location_outlined, color: AppColors.primary))),
              TextField(
                  controller: lng,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Longitude (optional)', prefixIcon: Icon(Icons.explore_outlined, color: AppColors.primary))),
              TextField(
                  controller: transport,
                  decoration: const InputDecoration(
                      labelText: 'Transport information (optional)', prefixIcon: Icon(Icons.directions_bus_outlined, color: AppColors.primary))),
              TextField(
                  controller: parking,
                  decoration: const InputDecoration(
                      labelText: 'Parking information (optional)', prefixIcon: Icon(Icons.local_parking_outlined, color: AppColors.primary))),
              TextField(
                  controller: price,
                  decoration: const InputDecoration(
                      labelText: 'Ticket price (or Free)', prefixIcon: Icon(Icons.sell_outlined, color: AppColors.primary))),
              TextField(
                  controller: desc,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.notes_outlined, color: AppColors.primary))),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: FilledButton(
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
                            imageUrl = await Db.uploadImage(
                                    selectedImageBytes!, extension,
                                    folder: 'events')
                                .timeout(const Duration(seconds: 45));
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
              ))
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
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Create Event')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: _Panel(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: .12)), child: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 44)),
                const SizedBox(height: 16),
                Text('Create something memorable', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Start with a draft, then add your agenda and facilities.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.secondaryText, height: 1.5)),
                const SizedBox(height: 22),
                SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => form(context), icon: const Icon(Icons.add), label: const Text('Start a new event draft'))),
              ]),
            ),
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('My Events'),
          backgroundColor: AppColors.surface,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primaryDark,
            unselectedLabelColor: AppColors.secondaryText,
            tabs: const [
              Tab(text: 'Drafts'),
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Changes'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryDark,
          onPressed: () => form(context),
          icon: const Icon(Icons.add),
          label: const Text('Create Event'),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: Db.myEvents(),
          builder: (c, s) {
            if (!s.hasData) return const Center(child: CircularProgressIndicator());
            final docs = s.data!.docs;
            if (docs.isEmpty) {
              return const _EmptyOrganizerState(message: 'No events created yet');
            }
            const statusGroups = [
              'draft', 'pending', 'approved', 'changes_requested', 'rejected',
            ];
            return TabBarView(
              children: [
                for (final status in statusGroups)
                  _OrganizerEventList(
                    docs: docs.where((doc) => doc.data()['status'] == status).toList(),
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

// Clear, non-editable picker tiles; date/time are still saved as strings.
class _DateTimePickerTile extends StatelessWidget {
  final String label;
  final String selectedValue;
  final String placeholder;
  final String helper;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _DateTimePickerTile({
    required this.label,
    required this.selectedValue,
    required this.placeholder,
    required this.helper,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = selectedValue.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasValue ? selectedValue : placeholder,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: hasValue
                                ? AppColors.primaryDark
                                : AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          helper,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 23,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormGrabber extends StatelessWidget {
  const _FormGrabber();
  @override
  Widget build(BuildContext context) => Center(child: Container(width: 42, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(6))));
}

class _OrganizerDashboard extends StatelessWidget {
  final VoidCallback onCreate;
  const _OrganizerDashboard({required this.onCreate});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('Organizer Dashboard'), backgroundColor: AppColors.surface),
    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.primaryDark,
      onPressed: onCreate,
      icon: const Icon(Icons.add),
      label: const Text('Create Event'),
    ),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: Db.myEvents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        final published = docs.where((doc) => doc.data()['status'] == 'approved').length;
        final pending = docs.where((doc) => doc.data()['status'] == 'pending').length;
        final drafts = docs.where((doc) => doc.data()['status'] == 'draft').length;
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          children: [
            const _Eyebrow(label: 'ORGANIZER WORKSPACE'),
            const SizedBox(height: 8),
            Text('Welcome, $userName', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 25, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Your event activity at a glance', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFFE6B84F)]),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(children: [
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('CREATE & INSPIRE', style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                  SizedBox(height: 8),
                  Text('Bring your next event to life', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                  SizedBox(height: 6),
                  Text('Plan, publish and manage all your experiences.', style: TextStyle(fontSize: 11, height: 1.5, color: AppColors.primaryDark)),
                ])),
                const SizedBox(width: 12),
                Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .28)), child: const Icon(Icons.event_available_rounded, size: 33, color: AppColors.primaryDark)),
              ]),
            ),
            const SizedBox(height: 19),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 11,
              mainAxisSpacing: 11,
              mainAxisExtent: 108,
              children: [
                _DashboardMetric(label: 'Total Events', value: '${docs.length}', icon: Icons.event_outlined, color: AppColors.primary),
                _DashboardMetric(label: 'Published', value: '$published', icon: Icons.public_rounded, color: AppColors.success),
                _DashboardMetric(label: 'Pending Review', value: '$pending', icon: Icons.hourglass_top_rounded, color: AppColors.warning),
                _DashboardMetric(label: 'Drafts', value: '$drafts', icon: Icons.drafts_outlined, color: AppColors.info),
              ],
            ),
            const SizedBox(height: 26),
            const _SectionHeading(title: 'Recent Events', subtitle: 'Your latest event submissions', icon: Icons.history_rounded),
            const SizedBox(height: 13),
            if (docs.isEmpty) const _EmptyOrganizerState(message: 'No events created yet.'),
            for (final doc in docs.take(5))
              Padding(padding: const EdgeInsets.only(bottom: 12), child: _EventCard(data: doc.data(), status: doc.data()['status']?.toString() ?? 'draft')),
          ],
        );
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
    if (docs.isEmpty) return const _EmptyOrganizerState(message: 'No events in this list');
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
      children: [
        _SectionHeading(title: 'Event Submissions', subtitle: '${docs.length} events in this category', icon: Icons.event_note_outlined),
        const SizedBox(height: 13),
        for (final d in docs)
          Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: _Panel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _EventCard(data: d.data(), status: d.data()['status']?.toString() ?? 'draft', embedded: true),
                const SizedBox(height: 12),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 9),
                // Original action availability and navigation retained.
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 2,
                  runSpacing: 3,
                  children: [
                    if (d.data()['status'] == 'draft' || d.data()['status'] == 'changes_requested')
                      IconButton(icon: const Icon(Icons.publish_outlined, color: AppColors.success), tooltip: 'Publish for admin review', onPressed: () => Db.publishEvent(d.id)),
                    if (d.data()['status'] == 'draft' || d.data()['status'] == 'changes_requested')
                      IconButton(icon: const Icon(Icons.event_note_outlined, color: AppColors.primary), tooltip: 'Agenda', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrganizerScheduleEditorScreen(eventId: d.id, eventTitle: d['title'] ?? 'Untitled event')))),
                    IconButton(icon: const Icon(Icons.business_outlined, color: AppColors.primary), tooltip: 'Manage Facilities', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrganizerFacilitiesScreen(eventId: d.id, eventTitle: d['title'] ?? 'Untitled event')))),
                    IconButton(icon: const Icon(Icons.photo_library_outlined, color: AppColors.primary), tooltip: 'Event gallery', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventGalleryScreen(eventId: d.id, eventTitle: d['title'] ?? 'Untitled event', mode: GalleryMode.organizer)))),
                    IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.primaryDark), tooltip: 'Edit event', onPressed: () => onEdit(d)),
                    IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), tooltip: 'Delete event', onPressed: () => Db.deleteEvent(d.id)),
                  ],
                ),
              ]),
            ),
          ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String status;
  final bool embedded;
  const _EventCard({required this.data, required this.status, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final contents = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      EventImage(url: data['imageUrl']?.toString(), width: 86, height: 99, borderRadius: BorderRadius.circular(12)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _StatusBadge(status: status),
        const SizedBox(height: 5),
        Text(data['title']?.toString() ?? 'Untitled event', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        _MetaRow(icon: Icons.calendar_today_outlined, text: data['date']?.toString() ?? ''),
        const SizedBox(height: 5),
        _MetaRow(icon: Icons.location_on_outlined, text: data['location']?.toString() ?? ''),
      ])),
    ]);
    return embedded ? contents : _Panel(child: contents);
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
      boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: .035), blurRadius: 15, offset: const Offset(0, 5))],
    ),
    child: child,
  );
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 13, color: AppColors.primary),
    const SizedBox(width: 5),
    Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.secondaryText, fontSize: 10))),
  ]);
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _SectionHeading({required this.title, required this.subtitle, required this.icon});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary, size: 21)),
    const SizedBox(width: 11),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 3),
      Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
    ])),
  ]);
}

class _Eyebrow extends StatelessWidget {
  final String label;
  const _Eyebrow({required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 22, height: 3, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6))),
    const SizedBox(width: 8),
    Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.primary)),
  ]);
}

class _EmptyOrganizerState extends StatelessWidget {
  final String message;
  const _EmptyOrganizerState({required this.message});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.all(23), decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: .11)), child: const Icon(Icons.event_busy_outlined, size: 40, color: AppColors.primary)),
      const SizedBox(height: 15),
      Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 5),
      const Text('Your events will appear here.', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
    ]),
  ));
}

class _DashboardMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _DashboardMetric({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => _Panel(
    child: Row(children: [
      Container(width: 37, height: 37, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 10),
      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
        Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.secondaryText)),
      ])),
    ]),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)),
      child: Text(_statusText(status), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
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