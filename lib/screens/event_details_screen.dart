// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:typed_data';
// import '../services/db.dart';
// import '../services/event_utils.dart';
// import 'calendar_reminders_screen.dart';
// import 'map_directions_screen.dart';
// import 'schedule_facilities_screen.dart';
// import 'event_gallery_screen.dart';
// import '../widgets/ceylona_bottom_navigation.dart';
// import '../widgets/event_image.dart';
// import '../theme/app_theme.dart';

// class EventDetailsScreen extends StatefulWidget {
//   final String id;
//   final Map<String, dynamic> data;
//   const EventDetailsScreen({super.key, required this.id, required this.data});

//   @override
//   State<EventDetailsScreen> createState() => _EventDetailsScreenState();
// }

// class _EventDetailsScreenState extends State<EventDetailsScreen> {
//   final ctrl = TextEditingController();
//   Uint8List? selectedCommentImage;
//   String? selectedCommentExtension;
//   bool submittingComment = false;

//   @override
//   void dispose() {
//     ctrl.dispose();
//     super.dispose();
//   }

//   Future<void> _pickCommentImage() async {
//     final image = await ImagePicker().pickImage(
//         source: ImageSource.gallery, imageQuality: 80, maxWidth: 1400);
//     if (image == null) return;
//     final bytes = await image.readAsBytes();
//     if (bytes.length > 5 * 1024 * 1024) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text('Please choose an image smaller than 5 MB')));
//       }
//       return;
//     }
//     setState(() {
//       selectedCommentImage = bytes;
//       selectedCommentExtension = image.name.split('.').last.toLowerCase();
//     });
//   }

//   Future<String?> _uploadCommentImage(Uint8List? bytes, String? extension) =>
//       bytes == null
//           ? Future.value(null)
//           : Db.uploadImage(bytes, extension ?? 'jpg',
//               folder: 'events/${widget.id}/comments');

//   Future<void> _submitComment() async {
//     final text = ctrl.text.trim();
//     if (text.isEmpty && selectedCommentImage == null) return;
//     setState(() => submittingComment = true);
//     try {
//       final imageUrl = await _uploadCommentImage(
//           selectedCommentImage, selectedCommentExtension);
//       await Db.addComment(widget.id, text, imageUrl: imageUrl);
//       ctrl.clear();
//       if (mounted) {
//         setState(() {
//           selectedCommentImage = null;
//           selectedCommentExtension = null;
//         });
//       }
//     } on FirebaseException catch (error) {
//       _showCommentError(error.message ?? 'Could not post comment');
//     } on StateError catch (error) {
//       _showCommentError(error.message);
//     } finally {
//       if (mounted) setState(() => submittingComment = false);
//     }
//   }

//   void _showCommentError(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(message)));
//     }
//   }

//   Future<void> _editComment(
//       QueryDocumentSnapshot<Map<String, dynamic>> comment) async {
//     final text = TextEditingController(text: comment.data()['text'] ?? '');
//     String? imageUrl = comment.data()['imageUrl']?.toString();
//     Uint8List? replacementImage;
//     String? replacementExtension;
//     final saved = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => StatefulBuilder(
//         builder: (context, setDialogState) => AlertDialog(
//           title: const Text('Edit comment'),
//           content: Column(mainAxisSize: MainAxisSize.min, children: [
//             TextField(
//                 controller: text,
//                 maxLines: 4,
//                 decoration: const InputDecoration(
//                     hintText: 'Your comment', border: OutlineInputBorder())),
//             const SizedBox(height: 10),
//             if (imageUrl != null && replacementImage == null)
//               Image.network(imageUrl!, height: 90, fit: BoxFit.cover),
//             if (replacementImage != null)
//               Image.memory(replacementImage!, height: 90, fit: BoxFit.cover),
//             TextButton.icon(
//                 onPressed: () async {
//                   final image = await ImagePicker().pickImage(
//                       source: ImageSource.gallery,
//                       imageQuality: 80,
//                       maxWidth: 1400);
//                   if (image == null) return;
//                   final bytes = await image.readAsBytes();
//                   if (bytes.length > 5 * 1024 * 1024) return;
//                   setDialogState(() {
//                     replacementImage = bytes;
//                     replacementExtension =
//                         image.name.split('.').last.toLowerCase();
//                   });
//                 },
//                 icon: const Icon(Icons.image_outlined),
//                 label: const Text('Replace image')),
//             if (imageUrl != null || replacementImage != null)
//               TextButton(
//                   onPressed: () => setDialogState(() {
//                         imageUrl = null;
//                         replacementImage = null;
//                       }),
//                   child: const Text('Remove image')),
//           ]),
//           actions: [
//             TextButton(
//                 onPressed: () => Navigator.pop(dialogContext, false),
//                 child: const Text('Cancel')),
//             FilledButton(
//                 onPressed: () => Navigator.pop(dialogContext, true),
//                 child: const Text('Save')),
//           ],
//         ),
//       ),
//     );
//     if (saved != true ||
//         (text.text.trim().isEmpty &&
//             imageUrl == null &&
//             replacementImage == null)) {
//       text.dispose();
//       return;
//     }

//     try {
//       final uploaded =
//           await _uploadCommentImage(replacementImage, replacementExtension);
//       await Db.updateComment(widget.id, comment.id,
//           text: text.text, imageUrl: uploaded ?? imageUrl);
//     } on FirebaseException catch (error) {
//       _showCommentError(error.message ?? 'Could not update comment');
//     } on StateError catch (error) {
//       _showCommentError(error.message);
//     } finally {
//       text.dispose();
//     }
//   }

//   Future<void> _replyToComment(
//       QueryDocumentSnapshot<Map<String, dynamic>> comment) async {
//     final reply = TextEditingController();
//     final saved = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text('Reply to comment'),
//         content: TextField(
//           controller: reply,
//           maxLines: 4,
//           autofocus: true,
//           decoration: const InputDecoration(
//             hintText: 'Write your reply',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext, false),
//             child: const Text('Cancel'),
//           ),
//           FilledButton(
//             onPressed: () => Navigator.pop(dialogContext, true),
//             child: const Text('Reply'),
//           ),
//         ],
//       ),
//     );
//     if (saved != true || reply.text.trim().isEmpty) {
//       reply.dispose();
//       return;
//     }
//     try {
//       await Db.replyToComment(widget.id, comment.id, reply.text);
//     } on FirebaseException catch (error) {
//       _showCommentError(error.message ?? 'Could not send reply');
//     } on StateError catch (error) {
//       _showCommentError(error.message);
//     } finally {
//       reply.dispose();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: const Icon(Icons.arrow_back_ios_new, size: 18)),
//         title: Text(widget.data['title'],
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//       ),
//       body: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
//           children: [
//             Stack(children: [
//               ClipRRect(
//                   borderRadius: BorderRadius.circular(14),
//                   child: EventImage(
//                       url: widget.data['imageUrl']?.toString(),
//                       height: 220,
//                       borderRadius: BorderRadius.circular(14))),
//               Positioned(
//                   right: 10,
//                   bottom: 10,
//                   child: FilledButton.icon(
//                       onPressed: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (_) => EventGalleryScreen(
//                                   eventId: widget.id,
//                                   eventTitle:
//                                       widget.data['title']?.toString() ??
//                                           'Event',
//                                   mode: GalleryMode.seeker))),
//                       icon: const Icon(Icons.photo_library_outlined, size: 16),
//                       label: const Text('View Photo Gallery'),
//                       style: FilledButton.styleFrom(
//                           backgroundColor: AppColors.primary,
//                           foregroundColor: AppColors.primaryDark))),
//             ]),
//             const SizedBox(height: 14),
//             Row(children: [
//               Chip(
//                   label: Text(widget.data['category']?.toString() ?? 'Event'),
//                   visualDensity: VisualDensity.compact),
//               const SizedBox(width: 8),
//               const Icon(Icons.verified, size: 16, color: AppColors.success),
//               const SizedBox(width: 4),
//               const Text('Verified organizer', style: TextStyle(fontSize: 12)),
//             ]),
//             Text(widget.data['title']?.toString() ?? 'Event',
//                 style: Theme.of(context).textTheme.headlineSmall),
//             const SizedBox(height: 12),
//             Card(
//                 color: const Color(0xfffff3c4),
//                 child: Padding(
//                     padding: const EdgeInsets.all(13),
//                     child: Row(children: [
//                       const Icon(Icons.confirmation_number_outlined),
//                       const SizedBox(width: 10),
//                       Expanded(
//                           child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                             const Text('Ticket price',
//                                 style: TextStyle(fontSize: 11)),
//                             Text(widget.data['price']?.toString() ?? 'Free',
//                                 style: const TextStyle(
//                                     fontSize: 16, fontWeight: FontWeight.w800)),
//                           ])),
//                       const Chip(
//                           label: Text('Presale active'),
//                           visualDensity: VisualDensity.compact),
//                     ]))),
//             const SizedBox(height: 8),
//             _EventInfoTile(
//                 icon: Icons.calendar_month_outlined,
//                 title: '${widget.data['date'] ?? ''}',
//                 subtitle: widget.data['time']?.toString() ?? ''),
//             _EventInfoTile(
//                 icon: Icons.location_on_outlined,
//                 title: widget.data['location']?.toString() ?? 'Location',
//                 subtitle: widget.data['address']?.toString() ?? 'Sri Lanka'),
//             const SizedBox(height: 6),
//             Row(children: [
//               Expanded(
//                   child: _ActionButton(
//                       icon: Icons.map_outlined,
//                       label: 'View Map',
//                       onPressed: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (_) =>
//                                   MapDirectionsScreen(event: widget.data))))),
//               const SizedBox(width: 8),
//               Expanded(
//                   child: _ActionButton(
//                       icon: Icons.alarm_add_outlined,
//                       label: 'Set Reminder',
//                       dark: true,
//                       onPressed: () => _setReminder(context))),
//               const SizedBox(width: 8),
//               Expanded(
//                   child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//                       stream: Db.saved(),
//                       builder: (context, snapshot) {
//                         final isSaved = snapshot.data?.docs
//                                 .any((doc) => doc.id == widget.id) ??
//                             false;
//                         return _ActionButton(
//                             icon: isSaved
//                                 ? Icons.bookmark
//                                 : Icons.bookmark_border,
//                             label: isSaved ? 'Saved' : 'Save',
//                             onPressed: isSaved
//                                 ? null
//                                 : () async {
//                                     await Db.saveEvent(widget.id, widget.data);
//                                     if (context.mounted) {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(const SnackBar(
//                                               content: Text('Event saved')));
//                                     }
//                                   });
//                       })),
//             ]),
//             const SizedBox(height: 22),
//             const Text('About the Event',
//                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
//             const SizedBox(height: 8),
//             Text(
//                 widget.data['description']?.toString() ??
//                     'No description provided.',
//                 style: const TextStyle(height: 1.45)),
//             if (widget.data['transportInfo']?.toString().isNotEmpty ==
//                 true) ...[
//               const SizedBox(height: 18),
//               const Text('Getting there',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
//               const SizedBox(height: 6),
//               Text(widget.data['transportInfo'].toString()),
//             ],
//             if (widget.data['parkingInfo']?.toString().isNotEmpty == true) ...[
//               const SizedBox(height: 12),
//               Text('Parking: ${widget.data['parkingInfo']}',
//                   style: const TextStyle(color: Colors.black54)),
//             ],
//             OutlinedButton.icon(
//               icon: const Icon(Icons.schedule),
//               label: const Text('View Schedule & Facilities'),
//               onPressed: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (_) =>
//                           ScheduleFacilitiesScreen(eventId: widget.id))),
//             ),
//             const Divider(height: 32),
//             const Text('Discussion',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             if (selectedCommentImage != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: Stack(children: [
//                   ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.memory(selectedCommentImage!,
//                           height: 90, width: 120, fit: BoxFit.cover)),
//                   Positioned(
//                       right: 0,
//                       top: 0,
//                       child: IconButton(
//                           onPressed: () =>
//                               setState(() => selectedCommentImage = null),
//                           icon: const Icon(Icons.close, color: Colors.white)))
//                 ]),
//               ),
//             Row(children: [
//               Expanded(
//                   child: TextField(
//                       controller: ctrl,
//                       decoration:
//                           const InputDecoration(hintText: 'Add a comment'))),
//               IconButton(
//                   tooltip: 'Add image',
//                   icon: const Icon(Icons.image_outlined),
//                   onPressed: submittingComment ? null : _pickCommentImage),
//               IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: submittingComment ? null : _submitComment)
//             ]),
//             StreamBuilder(
//               stream: Db.comments(widget.id),
//               builder: (c, s) {
//                 if (!s.hasData) return const SizedBox();
//                 return Column(children: [
//                   for (final d in s.data!.docs)
//                     Card(
//                         child: Padding(
//                             padding: const EdgeInsets.all(8),
//                             child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   ListTile(
//                                     contentPadding: EdgeInsets.zero,
//                                     title: Text(d['userName'] ?? ''),
//                                     subtitle: Text(d['text'] ?? ''),
//                                     trailing: d['userId'] == uid ||
//                                             widget.data['organizerId'] == uid
//                                         ? Wrap(children: [
//                                             if (widget.data['organizerId'] ==
//                                                     uid &&
//                                                 d['userId'] != uid)
//                                               IconButton(
//                                                 tooltip: 'Reply to comment',
//                                                 icon: const Icon(
//                                                     Icons.reply_outlined),
//                                                 onPressed: () =>
//                                                     _replyToComment(d),
//                                               ),
//                                             if (d['userId'] == uid)
//                                               IconButton(
//                                                 tooltip: 'Edit comment',
//                                                 icon: const Icon(
//                                                     Icons.edit_outlined),
//                                                 onPressed: () =>
//                                                     _editComment(d),
//                                               ),
//                                             if (d['userId'] == uid)
//                                               IconButton(
//                                                   tooltip: 'Delete comment',
//                                                   icon: const Icon(
//                                                       Icons.delete_outline),
//                                                   onPressed: () =>
//                                                       Db.deleteComment(
//                                                           widget.id, d.id)),
//                                           ])
//                                         : null,
//                                   ),
//                                   if (d
//                                           .data()['replyText']
//                                           ?.toString()
//                                           .trim()
//                                           .isNotEmpty ==
//                                       true)
//                                     Container(
//                                       width: double.infinity,
//                                       margin: const EdgeInsets.only(top: 6),
//                                       padding: const EdgeInsets.all(10),
//                                       decoration: BoxDecoration(
//                                         color: AppColors.primary
//                                             .withValues(alpha: .07),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: Text(
//                                         'Organizer reply: ${d.data()['replyText']}',
//                                       ),
//                                     ),
//                                   if (d
//                                           .data()['imageUrl']
//                                           ?.toString()
//                                           .isNotEmpty ==
//                                       true)
//                                     ClipRRect(
//                                         borderRadius: BorderRadius.circular(8),
//                                         child: Image.network(
//                                             d.data()['imageUrl'].toString(),
//                                             height: 150,
//                                             width: double.infinity,
//                                             fit: BoxFit.cover))
//                                 ])))
//                 ]);
//               },
//             ),
//           ]),
//       bottomNavigationBar: const CeylonaBottomNavigation(selectedIndex: 0),
//     );
//   }

//   Future<void> _setReminder(BuildContext context) async {
//     final eventTime = parseEventDateTime(widget.data);
//     if (eventTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text('Add a valid event date and time first.')));
//       return;
//     }
//     await Db.saveEvent(widget.id, widget.data);
//     if (!context.mounted) return;
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (_) => CalendarRemindersScreen(
//                   eventId: widget.id,
//                   eventData: widget.data,
//                 )));
//   }
// }

// class _EventInfoTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   const _EventInfoTile(
//       {required this.icon, required this.title, required this.subtitle});

//   @override
//   Widget build(BuildContext context) => Card(
//         child: ListTile(
//           leading: CircleAvatar(
//               backgroundColor: AppColors.primary.withValues(alpha: .14),
//               child: Icon(icon, color: AppColors.primaryDark, size: 19)),
//           title: Text(title,
//               style:
//                   const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
//           subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
//         ),
//       );
// }

// class _ActionButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback? onPressed;
//   final bool dark;
//   const _ActionButton(
//       {required this.icon,
//       required this.label,
//       required this.onPressed,
//       this.dark = false});

//   @override
//   Widget build(BuildContext context) => SizedBox(
//         height: 42,
//         child: FilledButton.icon(
//           onPressed: onPressed,
//           icon: Icon(icon, size: 15),
//           label: Text(label, style: const TextStyle(fontSize: 10)),
//           style: FilledButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 6),
//               backgroundColor: dark ? AppColors.primaryDark : AppColors.primary,
//               foregroundColor: dark ? Colors.white : AppColors.primaryDark),
//         ),
//       );
// }


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

  const EventDetailsScreen({
    super.key,
    required this.id,
    required this.data,
  });

  @override
  State<EventDetailsScreen> createState() =>
      _EventDetailsScreenState();
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

  // ============================================================
  // ORIGINAL BACKEND: PICK COMMENT IMAGE
  // ============================================================

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

  // ============================================================
  // ORIGINAL BACKEND: SUBMIT COMMENT
  // ============================================================

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

  // ============================================================
  // ORIGINAL BACKEND: EDIT COMMENT
  // ============================================================

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
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit comment',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: text,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      hintText: 'Your comment', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              if (imageUrl != null && replacementImage == null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(imageUrl!, height: 90, fit: BoxFit.cover),
                ),
              if (replacementImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    replacementImage!,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
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
          ),
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

  // ============================================================
  // ORIGINAL BACKEND: REPLY TO COMMENT
  // ============================================================

  Future<void> _replyToComment(
      QueryDocumentSnapshot<Map<String, dynamic>> comment) async {
    final reply = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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

  // ============================================================
  // MAIN PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.primaryDark,
          ),
        ),
        title: Text(
          'Event Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _buildHeroImage(),

          Padding(
            padding: const EdgeInsets.fromLTRB(17, 20, 17, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryRow(),

                const SizedBox(height: 14),

                Text(
                  widget.data['title']?.toString() ?? 'Event',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        color: AppColors.primaryDark,
                      ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Discover everything about this event',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),

                const SizedBox(height: 22),

                _buildTicketCard(),

                const SizedBox(height: 26),

                _buildSectionHeading(
                  'Event Information',
                  'Everything you need to know',
                  Icons.info_outline_rounded,
                ),

                const SizedBox(height: 14),

                _EventInfoTile(
                  icon: Icons.calendar_month_rounded,
                  label: 'DATE & TIME',
                  title: '${widget.data['date'] ?? ''}',
                  subtitle: widget.data['time']?.toString() ?? '',
                ),

                const SizedBox(height: 11),

                _EventInfoTile(
                  icon: Icons.location_on_rounded,
                  label: 'EVENT LOCATION',
                  title: widget.data['location']?.toString() ?? 'Location',
                  subtitle: widget.data['address']?.toString() ?? 'Sri Lanka',
                ),

                const SizedBox(height: 20),

                _buildActionButtons(),

                const SizedBox(height: 28),

                _buildSectionHeading(
                  'About the Event',
                  'Learn more about this experience',
                  Icons.article_outlined,
                ),

                const SizedBox(height: 13),

                _buildAboutCard(),

                if (widget.data['transportInfo']
                        ?.toString()
                        .isNotEmpty ==
                    true) ...[
                  const SizedBox(height: 23),
                  _buildSectionHeading(
                    'Getting There',
                    'Plan your journey',
                    Icons.directions_car_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildInformationCard(
                    Icons.directions_rounded,
                    widget.data['transportInfo'].toString(),
                  ),
                ],

                if (widget.data['parkingInfo']
                        ?.toString()
                        .isNotEmpty ==
                    true) ...[
                  const SizedBox(height: 12),
                  _buildInformationCard(
                    Icons.local_parking_rounded,
                    'Parking: ${widget.data['parkingInfo']}',
                  ),
                ],

                const SizedBox(height: 22),

                _buildScheduleButton(),

                const SizedBox(height: 30),

                _buildSectionHeading(
                  'Discussion',
                  'Join the conversation',
                  Icons.forum_outlined,
                ),

                const SizedBox(height: 15),

                _buildCommentComposer(),

                const SizedBox(height: 18),

                _buildCommentsList(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CeylonaBottomNavigation(selectedIndex: 0),
    );
  }

  // ============================================================
  // HERO IMAGE
  // ============================================================

  Widget _buildHeroImage() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 255,
          child: EventImage(
            url: widget.data['imageUrl']?.toString(),
            height: 255,
            borderRadius: BorderRadius.zero,
          ),
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.36),
                  ],
                ),
              ),
            ),
          ),
        ),

        Positioned(
          left: 16,
          top: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: AppColors.success,
                  size: 15,
                ),
                SizedBox(width: 5),
                Text(
                  'Verified Event',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          right: 15,
          bottom: 15,
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventGalleryScreen(
                    eventId: widget.id,
                    eventTitle:
                        widget.data['title']?.toString() ?? 'Event',
                    mode: GalleryMode.seeker,
                  ),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 17,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'View Gallery',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORY AND VERIFIED ORGANIZER
  // ============================================================

  Widget _buildCategoryRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            widget.data['category']?.toString() ?? 'Event',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 11),
        const Icon(
          Icons.verified_rounded,
          color: AppColors.success,
          size: 16,
        ),
        const SizedBox(width: 5),
        const Expanded(
          child: Text(
            'Verified organizer',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TICKET PRICE CARD
  // ============================================================

  Widget _buildTicketCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 24,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TICKET PRICE',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.data['price']?.toString() ?? 'Free',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text(
              'Presale active',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADING
  // ============================================================

  Widget _buildSectionHeading(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTION BUTTONS
  // ============================================================

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.map_outlined,
            label: 'View Map',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    MapDirectionsScreen(event: widget.data),
              ),
            ),
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: _ActionButton(
            icon: Icons.alarm_add_outlined,
            label: 'Set Reminder',
            dark: true,
            onPressed: () => _setReminder(context),
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: Db.saved(),
            builder: (context, snapshot) {
              final isSaved = snapshot.data?.docs
                      .any((doc) => doc.id == widget.id) ??
                  false;

              return _ActionButton(
                icon: isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                label: isSaved ? 'Saved' : 'Save',
                onPressed: isSaved
                    ? null
                    : () async {
                        await Db.saveEvent(widget.id, widget.data);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Event saved'),
                            ),
                          );
                        }
                      },
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ABOUT CARD
  // ============================================================

  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        widget.data['description']?.toString() ??
            'No description provided.',
        style: const TextStyle(
          fontSize: 12,
          height: 1.75,
          color: AppColors.secondaryText,
        ),
      ),
    );
  }

  // ============================================================
  // TRANSPORT AND PARKING
  // ============================================================

  Widget _buildInformationCard(IconData icon, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                height: 1.7,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCHEDULE AND FACILITIES
  // ============================================================

  Widget _buildScheduleButton() {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ScheduleFacilitiesScreen(eventId: widget.id),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule & Facilities',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'View agenda and available facilities',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primaryDark,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COMMENT COMPOSER
  // ============================================================

  Widget _buildCommentComposer() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.background,
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Share your thoughts',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          TextField(
            controller: ctrl,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write a comment about this event...',
              hintStyle: const TextStyle(fontSize: 11),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.all(13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          if (selectedCommentImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 11),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      selectedCommentImage!,
                      height: 100,
                      width: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: IconButton(
                      onPressed: () =>
                          setState(() => selectedCommentImage = null),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        iconSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          Row(
            children: [
              TextButton.icon(
                onPressed:
                    submittingComment ? null : _pickCommentImage,
                icon: const Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 19,
                ),
                label: const Text(
                  'Add Photo',
                  style: TextStyle(fontSize: 11),
                ),
              ),

              const Spacer(),

              FilledButton.icon(
                onPressed:
                    submittingComment ? null : _submitComment,
                icon: submittingComment
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 16),
                label: Text(
                  submittingComment ? 'Posting...' : 'Post Comment',
                  style: const TextStyle(fontSize: 11),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 41),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ORIGINAL COMMENTS STREAM
  // ============================================================

  Widget _buildCommentsList() {
    return StreamBuilder(
      stream: Db.comments(widget.id),
      builder: (c, s) {
        if (!s.hasData) return const SizedBox();

        final comments = s.data!.docs;

        if (comments.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 30,
              horizontal: 18,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
                SizedBox(height: 10),
                Text(
                  'No comments yet',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Be the first to start a conversation',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Text(
                    'Community Comments',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${comments.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            for (final d in comments)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCommentCard(d),
              ),
          ],
        );
      },
    );
  }

  // ============================================================
  // COMMENT CARD
  // ============================================================

  Widget _buildCommentCard(
      QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final commentData = d.data();

    final isOwner = d['userId'] == uid;
    final isOrganizer = widget.data['organizerId'] == uid;

    final hasReply =
        commentData['replyText']?.toString().trim().isNotEmpty == true;

    final hasImage =
        commentData['imageUrl']?.toString().isNotEmpty == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.background,
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['userName'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Community member',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              // Original permission logic is preserved.
              if (isOwner || isOrganizer)
                PopupMenuButton<String>(
                  tooltip: 'Comment options',
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.secondaryText,
                  ),
                  color: AppColors.surface,
                  onSelected: (action) {
                    if (action == 'reply') {
                      _replyToComment(d);
                    } else if (action == 'edit') {
                      _editComment(d);
                    } else if (action == 'delete') {
                      Db.deleteComment(widget.id, d.id);
                    }
                  },
                  itemBuilder: (context) => [
                    if (isOrganizer && !isOwner)
                      const PopupMenuItem(
                        value: 'reply',
                        child: Row(
                          children: [
                            Icon(Icons.reply_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Reply'),
                          ],
                        ),
                      ),
                    if (isOwner)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    if (isOwner)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text('Delete'),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            d['text'] ?? '',
            style: const TextStyle(
              fontSize: 12,
              height: 1.6,
              color: AppColors.secondaryText,
            ),
          ),

          if (hasImage) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                commentData['imageUrl'].toString(),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],

          if (hasReply) ...[
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: AppColors.primary,
                        size: 15,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Organizer Reply',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    commentData['replyText'].toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.6,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // ORIGINAL BACKEND: SET REMINDER
  // ============================================================

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

// ============================================================
// EVENT INFO TILE
// ============================================================

class _EventInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final String subtitle;

  const _EventInfoTile({
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACTION BUTTON
// ============================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool dark;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = dark
        ? AppColors.primaryDark
        : AppColors.primary;

    return SizedBox(
      height: 73,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Opacity(
            opacity: onPressed == null ? 0.55 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 9,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 21,
                    color: dark
                        ? Colors.white
                        : AppColors.primaryDark,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: dark
                          ? Colors.white
                          : AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}