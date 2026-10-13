// import 'package:flutter/material.dart';
// import '../services/db.dart';

// class OrganizerScheduleEditorScreen extends StatefulWidget {
//   final String eventId;
//   final String eventTitle;
//   const OrganizerScheduleEditorScreen(
//       {super.key, required this.eventId, required this.eventTitle});

//   @override
//   State<OrganizerScheduleEditorScreen> createState() =>
//       _OrganizerScheduleEditorScreenState();
// }

// class _OrganizerScheduleEditorScreenState
//     extends State<OrganizerScheduleEditorScreen> {
//   Future<void> _editAgenda(
//       BuildContext context, Map<String, dynamic>? existing) async {
//     final time = TextEditingController(text: existing?['time']?.toString());
//     final activity =
//         TextEditingController(text: existing?['activity']?.toString());
//     final confirmed = await showDialog<bool>(
//         context: context,
//         builder: (dialogContext) => AlertDialog(
//                 title: const Text('Add Agenda Item'),
//                 content: Column(mainAxisSize: MainAxisSize.min, children: [
//                   TextField(
//                       controller: time,
//                       decoration: const InputDecoration(labelText: 'Time')),
//                   TextField(
//                       controller: activity,
//                       decoration: const InputDecoration(labelText: 'Activity'))
//                 ]),
//                 actions: [
//                   TextButton(
//                       onPressed: () => Navigator.pop(dialogContext),
//                       child: const Text('Cancel')),
//                   FilledButton(
//                       onPressed: () => Navigator.pop(dialogContext, true),
//                       child: Text(existing == null ? 'Add' : 'Save'))
//                 ]));
//     if (confirmed == true &&
//         time.text.trim().isNotEmpty &&
//         activity.text.trim().isNotEmpty) {
//       if (existing != null) {
//         await Db.removeAgendaItem(widget.eventId, existing);
//       }
//       await Db.addAgendaItem(
//           widget.eventId, time.text.trim(), activity.text.trim());
//     }
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AppBar(title: Text(widget.eventTitle)),
//         body: StreamBuilder(
//           stream: Db.event(widget.eventId),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             final data = snapshot.data!.data() ?? <String, dynamic>{};
//             final status = data['status']?.toString() ?? 'draft';
//             final agenda = (data['agenda'] as List?)
//                     ?.whereType<Map>()
//                     .map((item) => Map<String, dynamic>.from(item))
//                     .toList() ??
//                 [];
//             return ListView(padding: const EdgeInsets.all(16), children: [
//               const Text('Event Timeline',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               if (agenda.isEmpty)
//                 const Padding(
//                   padding: EdgeInsets.only(bottom: 8),
//                   child: Text('No agenda items yet. Add them only if needed.'),
//                 ),
//               for (final item in agenda)
//                 ListTile(
//                     contentPadding: EdgeInsets.zero,
//                     title: Text(item['activity'] ?? ''),
//                     leading: SizedBox(
//                         width: 62,
//                         child: Text(item['time'] ?? '',
//                             style:
//                                 const TextStyle(fontWeight: FontWeight.bold))),
//                     trailing: Wrap(children: [
//                       IconButton(
//                           icon: const Icon(Icons.edit_outlined),
//                           onPressed: () => _editAgenda(context, item)),
//                       IconButton(
//                           icon: const Icon(Icons.delete_outline),
//                           onPressed: () =>
//                               Db.removeAgendaItem(widget.eventId, item)),
//                     ]),
//                     onTap: () => _editAgenda(context, item)),
//               OutlinedButton.icon(
//                   onPressed: () => _editAgenda(context, null),
//                   icon: const Icon(Icons.add),
//                   label: const Text('Add Agenda Item')),
//               const SizedBox(height: 16),
//               if (status == 'draft' || status == 'changes_requested')
//                 FilledButton.icon(
//                     onPressed: () async {
//                       await Db.publishEvent(widget.eventId);
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text('Published for admin review')));
//                         Navigator.pop(context);
//                       }
//                     },
//                     icon: const Icon(Icons.publish_outlined),
//                     label: const Text('Publish for Admin Review')),
//               if (status == 'pending')
//                 const ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   leading: Icon(Icons.hourglass_top),
//                   title: Text('Pending admin review'),
//                   subtitle: Text(
//                       'You can keep this draft data here while the authority officer reviews it.'),
//                 ),
//             ]);
//           },
//         ),
//       );
// }



import 'package:flutter/material.dart';

import '../services/db.dart';
import '../theme/app_theme.dart';

class OrganizerScheduleEditorScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const OrganizerScheduleEditorScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<OrganizerScheduleEditorScreen> createState() =>
      _OrganizerScheduleEditorScreenState();
}

class _OrganizerScheduleEditorScreenState
    extends State<OrganizerScheduleEditorScreen> {
  // ============================================================
  // ORIGINAL BACKEND - ADD / EDIT AGENDA
  // ============================================================

  Future<void> _editAgenda(
    BuildContext context,
    Map<String, dynamic>? existing,
  ) async {
    final time = TextEditingController(
      text: existing?['time']?.toString(),
    );

    final activity = TextEditingController(
      text: existing?['activity']?.toString(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                existing == null
                    ? Icons.playlist_add_rounded
                    : Icons.edit_note_rounded,
                color: AppColors.primary,
                size: 23,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                existing == null
                    ? 'Add Agenda Item'
                    : 'Edit Agenda Item',
                style: Theme.of(dialogContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),

        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EVENT SCHEDULE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.secondaryText,
                ),
              ),

              const SizedBox(height: 13),

              TextField(
                controller: time,
                decoration: InputDecoration(
                  labelText: 'Time',
                  hintText: 'e.g. 09:00 AM',
                  prefixIcon: const Icon(
                    Icons.access_time_rounded,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),

              const SizedBox(height: 13),

              TextField(
                controller: activity,
                decoration: InputDecoration(
                  labelText: 'Activity',
                  hintText: 'e.g. Opening Ceremony',
                  prefixIcon: const Icon(
                    Icons.event_note_outlined,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ],
          ),
        ),

        actionsPadding: const EdgeInsets.fromLTRB(
          20, 0, 20, 17,
        ),

        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),

          FilledButton.icon(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            icon: const Icon(
              Icons.check_rounded,
              size: 17,
            ),
            label: Text(
              existing == null ? 'Add Item' : 'Save Changes',
            ),
          ),
        ],
      ),
    );

    // ORIGINAL VALIDATION AND DB OPERATIONS
    if (confirmed == true &&
        time.text.trim().isNotEmpty &&
        activity.text.trim().isNotEmpty) {
      if (existing != null) {
        await Db.removeAgendaItem(
          widget.eventId,
          existing,
        );
      }

      await Db.addAgendaItem(
        widget.eventId,
        time.text.trim(),
        activity.text.trim(),
      );
    }

    time.dispose();
    activity.dispose();
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            // FIXED PAGE HEADER
            _ScheduleHeader(
              title: widget.eventTitle,
              onBack: () => Navigator.pop(context),
            ),

            // ORIGINAL FIRESTORE STREAM
            Expanded(
              child: StreamBuilder(
                stream: Db.event(widget.eventId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Text(
                          'Could not load event: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  // ORIGINAL EVENT DATA LOGIC
                  final data =
                      snapshot.data!.data() ??
                          <String, dynamic>{};

                  final status =
                      data['status']?.toString() ??
                          'draft';

                  final agenda =
                      (data['agenda'] as List?)
                              ?.whereType<Map>()
                              .map(
                                (item) =>
                                    Map<String, dynamic>.from(
                                  item,
                                ),
                              )
                              .toList() ??
                          [];

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16, 20, 16, 30,
                    ),
                    children: [
                      // =========================================
                      // EVENT SUMMARY
                      // =========================================

                      _ScheduleSummaryCard(
                        eventTitle: widget.eventTitle,
                        count: agenda.length,
                        status: status,
                      ),

                      const SizedBox(height: 27),

                      // =========================================
                      // TIMELINE HEADING
                      // =========================================

                      _TimelineHeading(
                        count: agenda.length,
                      ),

                      const SizedBox(height: 16),

                      // =========================================
                      // AGENDA TIMELINE
                      // =========================================

                      if (agenda.isEmpty)
                        const _EmptyAgendaState()
                      else
                        Column(
                          children: [
                            for (var i = 0;
                                i < agenda.length;
                                i++)
                              _AgendaTimelineItem(
                                number: i + 1,
                                isLast:
                                    i == agenda.length - 1,
                                time: agenda[i]['time']
                                        ?.toString() ??
                                    '',
                                activity: agenda[i]
                                        ['activity']
                                        ?.toString() ??
                                    '',

                                // ORIGINAL EDIT ACTION
                                onEdit: () => _editAgenda(
                                  context,
                                  agenda[i],
                                ),

                                // ORIGINAL DELETE ACTION
                                onDelete: () =>
                                    Db.removeAgendaItem(
                                  widget.eventId,
                                  agenda[i],
                                ),
                              ),
                          ],
                        ),

                      const SizedBox(height: 18),

                      // =========================================
                      // ADD AGENDA ITEM
                      // =========================================

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _editAgenda(
                            context,
                            null,
                          ),
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            size: 19,
                          ),
                          label: const Text(
                            'Add Agenda Item',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primary,
                            ),
                            foregroundColor:
                                AppColors.primaryDark,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 23),

                      // =========================================
                      // PUBLISH OR PENDING STATUS
                      // =========================================

                      if (status == 'draft' ||
                          status == 'changes_requested')
                        _PublishSection(
                          onPublish: () async {
                            // ORIGINAL BACKEND
                            await Db.publishEvent(
                              widget.eventId,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Published for admin review',
                                  ),
                                ),
                              );

                              Navigator.pop(context);
                            }
                          },
                        ),

                      if (status == 'pending')
                        const _PendingReviewCard(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FIXED PAGE HEADER
// ============================================================

class _ScheduleHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _ScheduleHeader({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        19, 16, 19, 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(
              alpha: 0.045,
            ),
            blurRadius: 17,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: AppColors.background,
                borderRadius:
                    BorderRadius.circular(13),
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(13),
                  onTap: onBack,
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primaryDark,
                      size: 17,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_note_rounded,
                      color: AppColors.primary,
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'ORGANIZER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              const SizedBox(width: 42),
            ],
          ),

          const SizedBox(height: 23),

          Row(
            children: [
              Container(
                width: 22,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                      BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'EVENT PLANNING',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Event ',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),
                TextSpan(
                  text: 'Timeline',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EVENT SUMMARY CARD
// ============================================================

class _ScheduleSummaryCard extends StatelessWidget {
  final String eventTitle;
  final int count;
  final String status;

  const _ScheduleSummaryCard({
    required this.eventTitle,
    required this.count,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.11,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.24,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.view_timeline_outlined,
              color: AppColors.primary,
              size: 25,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'EVENT SCHEDULE',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryText,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$count Agenda ${count == 1 ? 'Item' : 'Items'}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),

                const SizedBox(height: 7),

                _ScheduleStatusBadge(
                  status: status,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EVENT STATUS BADGE
// ============================================================

class _ScheduleStatusBadge extends StatelessWidget {
  final String status;

  const _ScheduleStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;

    switch (status) {
      case 'approved':
        color = AppColors.success;
        break;
      case 'rejected':
        color = AppColors.error;
        break;
      case 'changes_requested':
        color = AppColors.info;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.secondaryText;
    }

    final label = status
        .replaceAll('_', ' ')
        .toUpperCase();

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.13),
          borderRadius:
              BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TIMELINE HEADING
// ============================================================

class _TimelineHeading extends StatelessWidget {
  final int count;

  const _TimelineHeading({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.12,
            ),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.format_list_bulleted_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Agenda & Activities',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
              ),

              const SizedBox(height: 3),

              const Text(
                'Organize your event step by step',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.12,
            ),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// VERTICAL AGENDA TIMELINE ITEM
// ============================================================

class _AgendaTimelineItem extends StatelessWidget {
  final int number;
  final bool isLast;
  final String time;
  final String activity;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AgendaTimelineItem({
    required this.number,
    required this.isLast,
    required this.time,
    required this.activity,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          // TIMELINE CONNECTOR
          SizedBox(
            width: 29,
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface,
                      width: 3,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 11),

          // AGENDA CARD
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 13,
              ),
              child: Material(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(17),
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(17),
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(17),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // AGENDA INFORMATION
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.11),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      color: AppColors.primary,
                                      size: 14,
                                    ),

                                    const SizedBox(width: 5),

                                    Flexible(
                                      child: Text(
                                        time,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight:
                                              FontWeight.w700,
                                          color:
                                              AppColors.primaryDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                activity,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontSize: 12,
                                      height: 1.4,
                                      fontWeight:
                                          FontWeight.w700,
                                      color:
                                          AppColors.primaryDark,
                                    ),
                              ),

                              const SizedBox(height: 6),

                              const Text(
                                'Tap to edit agenda item',
                                style: TextStyle(
                                  fontSize: 9,
                                  color:
                                      AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // AGENDA ACTIONS
                        PopupMenuButton<String>(
                          tooltip: 'Agenda item actions',
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            size: 20,
                            color: AppColors.secondaryText,
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit();
                            } else if (value == 'delete') {
                              onDelete();
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  SizedBox(width: 10),
                                  Text('Edit Agenda'),
                                ],
                              ),
                            ),

                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.error,
                                    size: 18,
                                  ),
                                  SizedBox(width: 10),
                                  Text('Delete Agenda'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY AGENDA STATE
// ============================================================

class _EmptyAgendaState extends StatelessWidget {
  const _EmptyAgendaState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 33,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_note_outlined,
              color: AppColors.primary,
              size: 36,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            'No Agenda Items Yet',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Build your event schedule by adding\n'
            'activities and their times.\n'
            'Agenda items are optional.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1.6,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PUBLISH SECTION
// ============================================================

class _PublishSection extends StatelessWidget {
  final VoidCallback onPublish;

  const _PublishSection({
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: AppColors.primary.withValues(
                alpha: 0.25,
              ),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 22,
              ),

              SizedBox(width: 12),

              Expanded(
                child: Text(
                  'When you publish, this event will be sent '
                  'for admin review before appearing publicly.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.6,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          height: 53,
          child: FilledButton.icon(
            onPressed: onPublish,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(
              Icons.publish_rounded,
              size: 19,
            ),
            label: const Text(
              'Publish for Admin Review',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PENDING REVIEW STATE
// ============================================================

class _PendingReviewCard extends StatelessWidget {
  const _PendingReviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(
          alpha: 0.11,
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.warning.withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.hourglass_top_rounded,
            size: 22,
            color: AppColors.warning,
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Admin Review',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'You can keep this draft data here while '
                  'the authority officer reviews it.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.6,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}