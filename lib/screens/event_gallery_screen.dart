// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// import '../services/db.dart';
// import '../widgets/event_image.dart';
// import '../widgets/ceylona_bottom_navigation.dart';
// import '../widgets/admin_brand_bar.dart';
// import '../widgets/admin_design.dart';
// import '../theme/app_theme.dart';

// enum GalleryMode { seeker, organizer, admin }

// class EventGalleryScreen extends StatefulWidget {
//   final String eventId;
//   final String eventTitle;
//   final GalleryMode mode;

//   const EventGalleryScreen({
//     super.key,
//     required this.eventId,
//     required this.eventTitle,
//     required this.mode,
//   });

//   @override
//   State<EventGalleryScreen> createState() => _EventGalleryScreenState();
// }

// class _EventGalleryScreenState extends State<EventGalleryScreen> {
//   bool uploading = false;

//   Future<void> _upload() async {
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
//     setState(() => uploading = true);
//     try {
//       final extension = image.name.split('.').last.toLowerCase();
//       final url = await Db.uploadImage(bytes, extension,
//           folder: 'events/${widget.eventId}/gallery');
//       await Db.addGalleryImage(widget.eventId, url, '');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text('Gallery image sent for admin approval')));
//       }
//     } on FirebaseException catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(error.message ?? 'Upload failed')));
//       }
//     } on StateError catch (error) {
//       if (mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(error.message)));
//       }
//     } finally {
//       if (mounted) setState(() => uploading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final includePending = widget.mode != GalleryMode.seeker;
//     final organizerOnly = widget.mode == GalleryMode.organizer;
//     return Scaffold(
//       appBar: widget.mode == GalleryMode.admin
//           ? AdminBrandBar(title: '${widget.eventTitle} Gallery')
//           : AppBar(title: Text('${widget.eventTitle} Gallery')),
//       bottomNavigationBar: widget.mode == GalleryMode.seeker
//           ? const CeylonaBottomNavigation(selectedIndex: 0)
//           : null,
//       floatingActionButton: widget.mode == GalleryMode.organizer
//           ? FloatingActionButton.extended(
//               onPressed: uploading ? null : _upload,
//               icon: const Icon(Icons.add_photo_alternate_outlined),
//               label: Text(uploading ? 'Uploading...' : 'Add image'))
//           : null,
//       body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: Db.eventGallery(widget.eventId,
//             includePending: includePending, organizerOnly: organizerOnly),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(
//                 child: Text('Could not load gallery: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final docs = [...snapshot.data!.docs]..sort((a, b) {
//               final aTime = a.data()['createdAt'] as Timestamp?;
//               final bTime = b.data()['createdAt'] as Timestamp?;
//               return (bTime?.millisecondsSinceEpoch ?? 0)
//                   .compareTo(aTime?.millisecondsSinceEpoch ?? 0);
//             });
//           if (docs.isEmpty) {
//             return Center(
//                 child: Text(widget.mode == GalleryMode.seeker
//                     ? 'No approved gallery images yet.'
//                     : 'No gallery images uploaded yet.'));
//           }
//           return GridView.builder(
//             padding: const EdgeInsets.all(12),
//             gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//                 maxCrossAxisExtent: 260,
//                 mainAxisExtent: 250,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12),
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final doc = docs[index];
//               final data = doc.data();
//               final status = data['status']?.toString() ?? 'pending';
//               return Card(
//                 clipBehavior: Clip.antiAlias,
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                           child: EventImage(
//                               url: data['imageUrl']?.toString(),
//                               height: double.infinity,
//                               borderRadius: BorderRadius.zero)),
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
//                         child: Row(children: [
//                           Expanded(
//                               child: widget.mode == GalleryMode.admin
//                                   ? AdminStatusChip(
//                                       label: status == 'approved'
//                                           ? 'Approved'
//                                           : 'Pending review',
//                                       color: status == 'approved'
//                                           ? AppColors.success
//                                           : AppColors.warning)
//                                   : Text(widget.mode == GalleryMode.seeker
//                                       ? 'Approved image'
//                                       : status)),
//                           if (widget.mode == GalleryMode.admin &&
//                               status == 'pending') ...[
//                             IconButton(
//                                 tooltip: 'Approve image',
//                                 icon: const Icon(Icons.check_circle,
//                                     color: Colors.green),
//                                 onPressed: () => Db.reviewGalleryImage(
//                                     widget.eventId, doc.id, 'approved')),
//                             IconButton(
//                                 tooltip: 'Reject image',
//                                 icon:
//                                     const Icon(Icons.cancel, color: Colors.red),
//                                 onPressed: () => Db.reviewGalleryImage(
//                                     widget.eventId, doc.id, 'rejected')),
//                           ],
//                           if (widget.mode == GalleryMode.organizer)
//                             IconButton(
//                                 tooltip: 'Delete image',
//                                 icon: const Icon(Icons.delete_outline),
//                                 onPressed: () => Db.deleteGalleryImage(
//                                     widget.eventId, doc.id)),
//                         ]),
//                       ),
//                     ]),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/db.dart';
import '../widgets/event_image.dart';
import '../widgets/ceylona_bottom_navigation.dart';
import '../widgets/admin_brand_bar.dart';
import '../theme/app_theme.dart';

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
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1400,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please choose an image smaller than 5 MB')),
        );
      }
      return;
    }
    setState(() => uploading = true);
    try {
      final extension = image.name.split('.').last.toLowerCase();
      final url = await Db.uploadImage(
        bytes,
        extension,
        folder: 'events/${widget.eventId}/gallery',
      );
      await Db.addGalleryImage(widget.eventId, url, '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gallery image sent for admin approval')),
        );
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Upload failed')),
        );
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final includePending = widget.mode != GalleryMode.seeker;
    final organizerOnly = widget.mode == GalleryMode.organizer;
    final isAdmin = widget.mode == GalleryMode.admin;
    final isOrganizer = widget.mode == GalleryMode.organizer;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isAdmin
          ? AdminBrandBar(title: '${widget.eventTitle} Gallery')
          : AppBar(
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Event Gallery',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
              ),
            ),
      bottomNavigationBar: widget.mode == GalleryMode.seeker
          ? const CeylonaBottomNavigation(selectedIndex: 0)
          : null,
      floatingActionButton: isOrganizer
          ? FloatingActionButton.extended(
              onPressed: uploading ? null : _upload,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryDark,
              icon: uploading
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: Text(uploading ? 'Uploading...' : 'Add image'),
            )
          : null,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: Db.eventGallery(
          widget.eventId,
          includePending: includePending,
          organizerOnly: organizerOnly,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _GalleryState(
              icon: Icons.cloud_off_outlined,
              title: 'Could not load gallery',
              description: '${snapshot.error}',
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          // Original newest-first sorting and filtering are preserved.
          final docs = [...snapshot.data!.docs]..sort((a, b) {
              final aTime = a.data()['createdAt'] as Timestamp?;
              final bTime = b.data()['createdAt'] as Timestamp?;
              return (bTime?.millisecondsSinceEpoch ?? 0)
                  .compareTo(aTime?.millisecondsSinceEpoch ?? 0);
            });
          final approved = docs.where((d) => d.data()['status'] == 'approved').length;
          final pending = docs.where((d) => (d.data()['status']?.toString() ?? 'pending') == 'pending').length;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Eyebrow(),
                      const SizedBox(height: 10),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: 'Event ',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                          ),
                          TextSpan(
                            text: 'Gallery',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        widget.eventTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _GallerySummary(
                        imageCount: docs.length,
                        approvedCount: approved,
                        pendingCount: pending,
                        mode: widget.mode,
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Container(
                            height: 39,
                            width: 39,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.photo_library_outlined,
                                color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('Gallery Photos',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                          Text('${docs.length} images',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.secondaryText,
                              )),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
              if (docs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _GalleryState(
                    icon: Icons.collections_outlined,
                    title: 'No gallery images yet',
                    description: widget.mode == GalleryMode.seeker
                        ? 'No approved gallery images yet.'
                        : 'No gallery images uploaded yet.',
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, isOrganizer ? 100 : 24),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.crossAxisExtent;
                      final columns = width >= 900 ? 4 : (width >= 570 ? 3 : 2);
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: isAdmin ? 254 : 236,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final doc = docs[index];
                            final data = doc.data();
                            final status = data['status']?.toString() ?? 'pending';
                            return _GalleryPhotoCard(
                              url: data['imageUrl']?.toString(),
                              status: status,
                              mode: widget.mode,
                              onApprove: () => Db.reviewGalleryImage(
                                widget.eventId, doc.id, 'approved',
                              ),
                              onReject: () => Db.reviewGalleryImage(
                                widget.eventId, doc.id, 'rejected',
                              ),
                              onDelete: () => Db.deleteGalleryImage(
                                widget.eventId, doc.id,
                              ),
                            );
                          },
                          childCount: docs.length,
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow();
  @override
  Widget build(BuildContext context) => const Row(
        children: [
          SizedBox(width: 23, child: Divider(color: AppColors.primary, thickness: 3)),
          SizedBox(width: 8),
          Text('CEYLONA MOMENTS',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w800,
              )),
        ],
      );
}

class _GallerySummary extends StatelessWidget {
  final int imageCount;
  final int approvedCount;
  final int pendingCount;
  final GalleryMode mode;
  const _GallerySummary({
    required this.imageCount,
    required this.approvedCount,
    required this.pendingCount,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final description = switch (mode) {
      GalleryMode.seeker => 'Explore approved event moments',
      GalleryMode.organizer => 'Upload photos for admin review',
      GalleryMode.admin => 'Review submitted event images',
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.11),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.23)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.collections_outlined,
                color: AppColors.primary, size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('EVENT PHOTO COLLECTION',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 9,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 6),
                Text('$imageCount ${imageCount == 1 ? 'Photo' : 'Photos'}',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 5),
                Text(description,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 10,
                    )),
                if (mode == GalleryMode.admin) ...[
                  const SizedBox(height: 9),
                  Text('$pendingCount pending  •  $approvedCount approved',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryPhotoCard extends StatelessWidget {
  final String? url;
  final String status;
  final GalleryMode mode;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDelete;

  const _GalleryPhotoCard({
    required this.url,
    required this.status,
    required this.mode,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = mode == GalleryMode.admin;
    final isOrganizer = mode == GalleryMode.organizer;
    final color = switch (status) {
      'approved' => AppColors.success,
      'rejected' => AppColors.error,
      _ => AppColors.warning,
    };
    final label = switch (status) {
      'approved' => 'Approved',
      'rejected' => 'Rejected',
      _ => 'Pending review',
    };

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: EventImage(
              url: url,
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.zero,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 9, 6, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        mode == GalleryMode.seeker ? 'Approved image' : label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: mode == GalleryMode.seeker
                              ? AppColors.success
                              : color,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isOrganizer)
                      IconButton(
                        tooltip: 'Delete image',
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        iconSize: 19,
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.error),
                      ),
                  ],
                ),
                if (isAdmin && status == 'pending') ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: _GalleryAction(
                          title: 'Approve',
                          icon: Icons.check_rounded,
                          color: AppColors.success,
                          onPressed: onApprove,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: _GalleryAction(
                          title: 'Reject',
                          icon: Icons.close_rounded,
                          color: AppColors.error,
                          onPressed: onReject,
                        ),
                      ),
                    ],
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

class _GalleryAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const _GalleryAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 13),
        label: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.35)),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          minimumSize: const Size(0, 32),
          textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
}

class _GalleryState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _GalleryState({
    required this.icon,
    required this.title,
    required this.description,
  });
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.11),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 35),
              ),
              const SizedBox(height: 14),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  )),
              const SizedBox(height: 7),
              Text(description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: AppColors.secondaryText,
                  )),
            ],
          ),
        ),
      );
}