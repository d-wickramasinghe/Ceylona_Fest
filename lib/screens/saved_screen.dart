// import 'package:flutter/material.dart';
// import '../services/db.dart';
// import 'event_details_screen.dart';
// import 'calendar_reminders_screen.dart';
// import '../widgets/seeker_page_header.dart';

// class SavedScreen extends StatelessWidget {
//   const SavedScreen({super.key});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//         backgroundColor: const Color(0xfffbfaf7),
//         body: Column(children: [
//           SeekerPageHeader(
//               title: 'Saved Events',
//               subtitle: 'Keep your next experiences close',
//               actions: [
//                 IconButton(
//                     tooltip: 'Calendar & reminders',
//                     icon: const Icon(Icons.calendar_month),
//                     onPressed: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => const CalendarRemindersScreen())))
//               ]),
//           Expanded(child: StreamBuilder(
//           stream: Db.saved(),
//           builder: (c, s) {
//             if (!s.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (s.data!.docs.isEmpty) {
//               return const Center(
//                   child: Column(mainAxisSize: MainAxisSize.min, children: [
//                 Icon(Icons.bookmark_border, size: 48),
//                 SizedBox(height: 8),
//                 Text('No More Saved Events',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 SizedBox(height: 4),
//                 Text(
//                     'Browse events and tap the bookmark icon to save them here')
//               ]));
//             }
//             return ListView(
//                 padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
//                 children: [
//                   Text('Upcoming Saved Events (${s.data!.docs.length})',
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.w700)),
//                   const SizedBox(height: 8),
//                   for (final d in s.data!.docs)
//                     Card(
//                       child: ListTile(
//                         title: Text(d['title']),
//                         subtitle: Text('${d['date']} • ${d['location']}'),
//                         onTap: () => Navigator.push(
//                             c,
//                             MaterialPageRoute(
//                                 builder: (_) => EventDetailsScreen(
//                                     id: d.id, data: d.data()))),
//                         trailing: IconButton(
//                             icon: const Icon(Icons.delete),
//                             onPressed: () => Db.unsaveEvent(d.id)),
//                       ),
//                     )
//                 ]);
//           },
//         )),
//         ]),
//       );
// }


import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/db.dart';
import 'event_details_screen.dart';
import 'calendar_reminders_screen.dart';
import '../widgets/event_image.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // FIXED MODERN HEADER
            // ==================================================
            _SavedPageHeader(
              onCalendar: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CalendarRemindersScreen(),
                ),
              ),
            ),

            // ==================================================
            // ORIGINAL FIRESTORE STREAM
            // ==================================================
            Expanded(
              child: StreamBuilder(
                stream: Db.saved(),
                builder: (c, s) {
                  if (!s.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  final docs = s.data!.docs;

                  if (docs.isEmpty) {
                    return const _SavedEmptyState();
                  }

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      22,
                      16,
                      28,
                    ),
                    children: [
                      // Saved events summary
                      _SavedSummaryCard(
                        count: docs.length,
                      ),

                      const SizedBox(height: 27),

                      // Section heading
                      _SavedSectionHeading(
                        count: docs.length,
                      ),

                      const SizedBox(height: 15),

                      // Existing saved Firestore documents
                      for (final d in docs)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 13,
                          ),
                          child: _SavedEventCard(
                            data: d.data(),
                            onTap: () => Navigator.push(
                              c,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EventDetailsScreen(
                                  id: d.id,
                                  data: d.data(),
                                ),
                              ),
                            ),

                            // ORIGINAL BACKEND - UNCHANGED
                            onRemove: () =>
                                Db.unsaveEvent(d.id),
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
}

// ============================================================
// MODERN SAVED PAGE HEADER
// ============================================================

class _SavedPageHeader extends StatelessWidget {
  final VoidCallback onCalendar;

  const _SavedPageHeader({
    required this.onCalendar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        19,
        16,
        19,
        22,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top navigation row
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
                      Icons.bookmarks_rounded,
                      color: AppColors.primary,
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'MY COLLECTION',
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

              // Calendar navigation
              Material(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  onTap: onCalendar,
                  borderRadius: BorderRadius.circular(13),
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      Icons.calendar_month_rounded,
                      size: 21,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Eyebrow label
          Row(
            children: [
              Container(
                height: 3,
                width: 22,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(width: 8),

              const Text(
                'YOUR FAVORITE MOMENTS',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Main title
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Saved ',
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
                  text: 'Events',
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
            'Keep your next experiences close.\n'
            'All your favorite events in one place.',
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
// SAVED EVENTS SUMMARY CARD
// ============================================================

class _SavedSummaryCard extends StatelessWidget {
  final int count;

  const _SavedSummaryCard({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.11,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.bookmark_rounded,
              color: AppColors.primary,
              size: 27,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR SAVED COLLECTION',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$count Saved ${count == 1 ? 'Event' : 'Events'}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Your next adventure is waiting',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.auto_awesome_rounded,
            size: 23,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION HEADING
// ============================================================

class _SavedSectionHeading extends StatelessWidget {
  final int count;

  const _SavedSectionHeading({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.12,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.event_available_rounded,
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
                'Your Saved Events',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
              ),

              const SizedBox(height: 3),

              const Text(
                'Explore your bookmarked experiences',
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
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SAVED EVENT CARD
// ============================================================

class _SavedEventCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SavedEventCard({
    required this.data,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        data['title']?.toString() ?? 'Untitled event';

    final date = data['date']?.toString() ?? '';
    final time = data['time']?.toString() ?? '';
    final location = data['location']?.toString() ?? '';
    final category = data['category']?.toString() ?? 'Event';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(
                  alpha: 0.035,
                ),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // Event image
              EventImage(
                url: data['imageUrl']?.toString(),
                width: 110,
                height: 135,
                borderRadius: BorderRadius.circular(13),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: SizedBox(
                  height: 135,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // Category and remove button
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(7),
                              ),
                              child: Text(
                                category,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),

                          // ORIGINAL UNSAVE ACTION
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              tooltip: 'Remove saved event',
                              icon: const Icon(
                                Icons.bookmark_remove_outlined,
                                color: AppColors.error,
                                size: 19,
                              ),
                              onPressed: onRemove,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 9),

                      // Event title
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontSize: 12.5,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                            ),
                      ),

                      const Spacer(),

                      // Date and time
                      _cardInfoRow(
                        Icons.calendar_month_rounded,
                        '$date${time.isNotEmpty ? ' • $time' : ''}',
                      ),

                      const SizedBox(height: 7),

                      // Location
                      _cardInfoRow(
                        Icons.location_on_outlined,
                        location,
                      ),

                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardInfoRow(
    IconData icon,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color: AppColors.primary,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MODERN EMPTY STATE
// ============================================================

class _SavedEmptyState extends StatelessWidget {
  const _SavedEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 26,
          vertical: 30,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.11,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 21),

            Text(
              'No Saved Events Yet',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Your saved experiences will appear here.\n'
              'Browse events and tap the bookmark icon\n'
              'to keep them close.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.7,
                color: AppColors.secondaryText,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_add_outlined,
                    size: 19,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Bookmark events to save them',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}