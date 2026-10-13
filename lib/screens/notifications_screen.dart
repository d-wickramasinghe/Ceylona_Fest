// import 'package:flutter/material.dart';
// import '../theme/app_theme.dart';
// import '../services/db.dart';
// import '../widgets/seeker_page_header.dart';

// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({super.key});

//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }

// class _NotificationsScreenState extends State<NotificationsScreen> {
//   int filter = 0;

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         backgroundColor: const Color(0xfffbfaf7),
//         body: Column(children: [
//           const SeekerPageHeader(
//               title: 'Your Alerts', subtitle: 'Updates from Ceylona'),
//           Expanded(child: StreamBuilder(
//           stream: Db.notifications(),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Center(
//                   child:
//                       Text('Could not load notifications: ${snapshot.error}'));
//             }
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             final docs = snapshot.data!.docs.where((doc) {
//               if (filter == 0) return true;
//               final text =
//                   '${doc.data()['title'] ?? ''} ${doc.data()['message'] ?? ''}'
//                       .toLowerCase();
//               return filter == 1
//                   ? !text.contains('reminder')
//                   : text.contains('reminder');
//             }).toList();
//             if (docs.isEmpty) {
//               return const Center(child: Text('You are all caught up'));
//             }
//             return Column(children: [
//               Padding(
//                   padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
//                   child: SegmentedButton<int>(
//                       segments: const [
//                         ButtonSegment(value: 0, label: Text('All')),
//                         ButtonSegment(value: 1, label: Text('Updates')),
//                         ButtonSegment(value: 2, label: Text('Reminders'))
//                       ],
//                       selected: {
//                         filter
//                       },
//                       onSelectionChanged: (value) =>
//                           setState(() => filter = value.first))),
//               Expanded(
//                   child: ListView.builder(
//                       padding: const EdgeInsets.all(12),
//                       itemCount: docs.length,
//                       itemBuilder: (context, index) {
//                         final data = docs[index].data();
//                         return Card(
//                             child: ListTile(
//                                 leading: CircleAvatar(
//                                     backgroundColor:
//                                         AppColors.warning.withValues(alpha: .16),
//                                     child:
//                                         const Icon(Icons.notifications_none)),
//                                 title: Text(data['title'] ?? 'Ceylona update',
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.w700)),
//                                 subtitle: Text(data['message'] ?? ''),
//                                 trailing: data['read'] == true
//                                     ? null
//                                     : const Icon(Icons.fiber_manual_record,
//                                         size: 12, color: AppColors.warning)));
//                       })),
//             ]);
//           },
//         )),
//         ]),
//       );
// }


import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/db.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  int filter = 0;

  // ============================================================
  // ORIGINAL FILTERING LOGIC
  // ============================================================

  IconData _notificationIcon(
    Map<String, dynamic> data,
  ) {
    final text =
        '${data['title'] ?? ''} ${data['message'] ?? ''}'
            .toLowerCase();

    if (text.contains('reminder')) {
      return Icons.alarm_rounded;
    }

    return Icons.notifications_active_outlined;
  }

  bool _isReminder(Map<String, dynamic> data) {
    final text =
        '${data['title'] ?? ''} ${data['message'] ?? ''}'
            .toLowerCase();

    return text.contains('reminder');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // FIXED PAGE HEADER
            // ==================================================

            const _NotificationsHeader(),

            // ==================================================
            // FIRESTORE NOTIFICATIONS STREAM
            // ==================================================

            Expanded(
              child: StreamBuilder(
                stream: Db.notifications(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _NotificationError(
                      message:
                          'Could not load notifications: ${snapshot.error}',
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  // ORIGINAL FILTERING - UNCHANGED
                  final docs = snapshot.data!.docs.where((doc) {
                    if (filter == 0) return true;

                    final text =
                        '${doc.data()['title'] ?? ''} '
                        '${doc.data()['message'] ?? ''}'
                            .toLowerCase();

                    return filter == 1
                        ? !text.contains('reminder')
                        : text.contains('reminder');
                  }).toList();

                  final allDocs = snapshot.data!.docs;

                  final unreadCount = allDocs
                      .where(
                        (doc) => doc.data()['read'] != true,
                      )
                      .length;

                  return Column(
                    children: [
                      // FILTER BAR
                      _buildFilters(),

                      // SCROLLABLE NOTIFICATIONS
                      Expanded(
                        child: ListView(
                          physics:
                              const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            17,
                            16,
                            28,
                          ),
                          children: [
                            // Notification overview
                            _NotificationSummary(
                              total: allDocs.length,
                              unread: unreadCount,
                            ),

                            const SizedBox(height: 25),

                            _buildSectionHeading(
                              docs.length,
                            ),

                            const SizedBox(height: 14),

                            if (docs.isEmpty)
                              _NotificationsEmptyState(
                                filter: filter,
                              )
                            else
                              for (final doc in docs)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    bottom: 12,
                                  ),
                                  child: _NotificationCard(
                                    title:
                                        doc.data()['title']
                                                ?.toString() ??
                                            'Ceylona update',
                                    message:
                                        doc.data()['message']
                                                ?.toString() ??
                                            '',
                                    isRead:
                                        doc.data()['read'] ==
                                            true,
                                    isReminder: _isReminder(
                                      doc.data(),
                                    ),
                                    icon: _notificationIcon(
                                      doc.data(),
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
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

  // ============================================================
  // FILTER BAR
  // ============================================================

  Widget _buildFilters() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        17,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _filterChip(
              label: 'All',
              icon: Icons.grid_view_rounded,
              value: 0,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: _filterChip(
              label: 'Updates',
              icon: Icons.campaign_outlined,
              value: 1,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: _filterChip(
              label: 'Reminders',
              icon: Icons.alarm_outlined,
              value: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required IconData icon,
    required int value,
  }) {
    final selected = filter == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => filter = value);
        },
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 190),
          curve: Curves.easeOut,
          height: 43,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.background,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? AppColors.primaryDark
                    : AppColors.secondaryText,
              ),

              const SizedBox(width: 6),

              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? AppColors.primaryDark
                        : AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADING
  // ============================================================

  Widget _buildSectionHeading(int count) {
    final title = filter == 0
        ? 'All Notifications'
        : filter == 1
            ? 'Recent Updates'
            : 'Event Reminders';

    final subtitle = filter == 0
        ? 'Stay updated with Ceylona'
        : filter == 1
            ? 'Latest updates and announcements'
            : 'Your event reminder notifications';

    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.12,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.notifications_active_outlined,
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
                title,
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
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MODERN NOTIFICATIONS HEADER
// ============================================================

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        19,
        17,
        19,
        24,
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
          // TOP ROW
          Row(
            children: [
              Material(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 17,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.primary,
                      size: 15,
                    ),

                    SizedBox(width: 6),

                    Text(
                      'NOTIFICATIONS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
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

          const SizedBox(height: 24),

          // EYEBROW
          Row(
            children: [
              Container(
                width: 22,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(width: 8),

              const Text(
                'STAY IN THE LOOP',
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
                  text: 'Your ',
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
                  text: 'Alerts',
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

          const Text(
            'Updates from Ceylona, all in one place.\n'
            'Never miss an event or important reminder.',
            style: TextStyle(
              fontSize: 11,
              height: 1.65,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NOTIFICATION SUMMARY CARD
// ============================================================

class _NotificationSummary extends StatelessWidget {
  final int total;
  final int unread;

  const _NotificationSummary({
    required this.total,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.22,
          ),
        ),
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
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.primary,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR NOTIFICATION CENTER',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$total Notifications',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),

                const SizedBox(height: 4),

                Text(
                  unread == 0
                      ? 'You are all caught up!'
                      : '$unread unread ${unread == 1 ? 'notification' : 'notifications'}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          if (unread > 0)
            Container(
              width: 29,
              height: 29,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                unread > 99 ? '99+' : '$unread',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// NOTIFICATION CARD
// ============================================================

class _NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final bool isRead;
  final bool isReminder;
  final IconData icon;

  const _NotificationCard({
    required this.title,
    required this.message,
    required this.isRead,
    required this.isReminder,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        isReminder ? AppColors.info : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRead
              ? AppColors.border
              : AppColors.primary.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(
              alpha: 0.03,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // NOTIFICATION ICON
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                      ),
                    ),

                    if (!isRead) ...[
                      const SizedBox(width: 7),
                      Container(
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.65,
                    color: AppColors.secondaryText,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isReminder ? 'REMINDER' : 'UPDATE',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
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

// ============================================================
// EMPTY NOTIFICATION STATE
// ============================================================

class _NotificationsEmptyState extends StatelessWidget {
  final int filter;

  const _NotificationsEmptyState({
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final title = filter == 2
        ? 'No Reminders Yet'
        : filter == 1
            ? 'No Updates Yet'
            : 'You Are All Caught Up!';

    final subtitle = filter == 2
        ? 'Your event reminders will appear here.'
        : filter == 1
            ? 'New updates will appear here.'
            : 'You have no notifications at the moment.\n'
              'Check back for exciting event updates.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 42,
        horizontal: 20,
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
            width: 89,
            height: 89,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.11,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
              size: 41,
            ),
          ),

          const SizedBox(height: 19),

          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
          ),

          const SizedBox(height: 9),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
// ERROR STATE
// ============================================================

class _NotificationError extends StatelessWidget {
  final String message;

  const _NotificationError({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 43,
            ),

            const SizedBox(height: 13),

            Text(
              'Could Not Load Notifications',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                height: 1.6,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}