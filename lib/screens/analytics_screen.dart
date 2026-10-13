// import 'package:flutter/material.dart';
// import '../theme/app_theme.dart';
// import '../services/db.dart';

// class AnalyticsScreen extends StatelessWidget {
//   const AnalyticsScreen({super.key});

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AppBar(title: const Text('Organizer Analytics')),
//         body: StreamBuilder(
//           stream: Db.myEvents(),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Center(
//                   child: Text('Could not load analytics: ${snapshot.error}'));
//             }
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             final events = snapshot.data!.docs;
//             final published = events
//                 .where((event) => event.data()['status'] == 'approved')
//                 .length;
//             final pending = events
//                 .where((event) => event.data()['status'] == 'pending')
//                 .length;
//             return ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 Text('Performance overview',
//                     style: Theme.of(context).textTheme.headlineSmall),
//                 const Text('Track how your published events are performing',
//                     style: TextStyle(color: Colors.grey)),
//                 const SizedBox(height: 16),
//                 Row(children: [
//                   Expanded(
//                       child: _Metric(
//                           label: 'Total events',
//                           value: '${events.length}',
//                           icon: Icons.event)),
//                   const SizedBox(width: 12),
//                   Expanded(
//                       child: _Metric(
//                           label: 'Published',
//                           value: '$published',
//                           icon: Icons.verified)),
//                 ]),
//                 const SizedBox(height: 12),
//                 Row(children: [
//                   Expanded(
//                       child: _Metric(
//                           label: 'Pending review',
//                           value: '$pending',
//                           icon: Icons.hourglass_top)),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                       child: _Metric(
//                           label: 'Interested users',
//                           value: '0',
//                           icon: Icons.people)),
//                 ]),
//                 const SizedBox(height: 24),
//                 const Text('Registration Trend',
//                     style:
//                         TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
//                 const SizedBox(height: 8),
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
//                     child: Column(children: [
//                       Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: const [
//                             Text('Last 7 days'),
//                             Chip(
//                                 label: Text('+24%',
//                                     style: TextStyle(color: AppColors.success))),
//                           ]),
//                       const SizedBox(height: 12),
//                       SizedBox(
//                         height: 120,
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.end,
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             for (final height in <double>[
//                               42,
//                               68,
//                               52,
//                               92,
//                               74,
//                               110,
//                               84
//                             ])
//                               Container(
//                                   width: 22,
//                                   height: height,
//                                   decoration: BoxDecoration(
//                                       color: Colors.amber.shade600,
//                                       borderRadius: BorderRadius.circular(5))),
//                           ],
//                         ),
//                       ),
//                     ]),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text('Attendance Breakup',
//                     style:
//                         TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
//                 Card(
//                     child: ListTile(
//                         leading: CircleAvatar(
//                             backgroundColor: AppColors.success.withValues(alpha: .12),
//                             child: const Icon(Icons.pie_chart_outline)),
//                         title: const Text('Registrations enabled soon'),
//                         subtitle: const Text(
//                             'Attendance and attendee analytics will appear when registration data is available.'))),
//               ],
//             );
//           },
//         ),
//       );
// }

// class _Metric extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   const _Metric({required this.label, required this.value, required this.icon});

//   @override
//   Widget build(BuildContext context) => Card(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child:
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Icon(icon),
//             const SizedBox(height: 12),
//             Text(value, style: Theme.of(context).textTheme.headlineMedium),
//             Text(label),
//           ]),
//         ),
//       );
// }


import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../services/db.dart';

// ============================================================
// ORGANIZER ANALYTICS SCREEN
// ============================================================

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _AnalyticsHeader(
              onBack: () => Navigator.pop(context),
            ),

            Expanded(
              child: StreamBuilder(
                // ORIGINAL FIRESTORE STREAM
                stream: Db.myEvents(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _AnalyticsMessage(
                      icon: Icons.error_outline_rounded,
                      title: 'Could Not Load Analytics',
                      message:
                          'Could not load analytics: ${snapshot.error}',
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  // ORIGINAL BACKEND COUNTING LOGIC
                  final events = snapshot.data!.docs;

                  final published = events
                      .where(
                        (event) =>
                            event.data()['status'] == 'approved',
                      )
                      .length;

                  final pending = events
                      .where(
                        (event) =>
                            event.data()['status'] == 'pending',
                      )
                      .length;

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      21,
                      16,
                      32,
                    ),
                    children: [
                      // OVERVIEW
                      _PerformanceSummary(
                        total: events.length,
                        published: published,
                      ),

                      const SizedBox(height: 26),

                      const _SectionHeading(
                        icon: Icons.insights_rounded,
                        title: 'Performance Overview',
                        subtitle: 'Your event activity at a glance',
                      ),

                      const SizedBox(height: 14),

                      // METRIC GRID
                      Row(
                        children: [
                          Expanded(
                            child: _Metric(
                              label: 'Total Events',
                              value: '${events.length}',
                              icon: Icons.event_note_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: _Metric(
                              label: 'Published',
                              value: '$published',
                              icon: Icons.verified_rounded,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 11),

                      Row(
                        children: [
                          Expanded(
                            child: _Metric(
                              label: 'Pending Review',
                              value: '$pending',
                              icon: Icons.hourglass_top_rounded,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 11),
                          const Expanded(
                            child: _Metric(
                              label: 'Interested Users',
                              value: '0',
                              icon: Icons.people_outline_rounded,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // REGISTRATION TREND
                      const _SectionHeading(
                        icon: Icons.bar_chart_rounded,
                        title: 'Registration Trend',
                        subtitle: 'Illustrative trend preview',
                      ),

                      const SizedBox(height: 14),

                      const _RegistrationTrendCard(),

                      const SizedBox(height: 27),

                      // ATTENDANCE
                      const _SectionHeading(
                        icon: Icons.groups_outlined,
                        title: 'Attendance Breakup',
                        subtitle: 'Registration and attendance insights',
                      ),

                      const SizedBox(height: 14),

                      const _AttendanceCard(),

                      const SizedBox(height: 22),

                      const _AnalyticsInfoNotice(),
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
// MODERN ANALYTICS HEADER
// ============================================================

class _AnalyticsHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _AnalyticsHeader({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(19, 16, 19, 23),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.045),
            blurRadius: 17,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(13),
                  child: const SizedBox(
                    height: 42,
                    width: 42,
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
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 15,
                      color: AppColors.primary,
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
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'EVENT PERFORMANCE',
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

          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Organizer ',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),
                TextSpan(
                  text: 'Analytics',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Track your event activity and discover\n'
            'insights from your organizer dashboard.',
            style: TextStyle(
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
// PERFORMANCE SUMMARY
// ============================================================

class _PerformanceSummary extends StatelessWidget {
  final int total;
  final int published;

  const _PerformanceSummary({
    required this.total,
    required this.published,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.query_stats_rounded,
              color: AppColors.primary,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR EVENT PERFORMANCE',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '$total Total ${total == 1 ? 'Event' : 'Events'}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),

                const SizedBox(height: 6),

                Text(
                  '$published published '
                  '${published == 1 ? 'event' : 'events'}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primary,
            size: 23,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION HEADING
// ============================================================

class _SectionHeading extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 41,
          height: 41,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 21,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

              const SizedBox(height: 4),

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
}

// ============================================================
// MODERN METRIC CARD
// ============================================================

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 141),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color:
                AppColors.primaryDark.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
          ),

          const SizedBox(height: 5),

          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REGISTRATION TREND - ORIGINAL SAMPLE VALUES
// ============================================================

class _RegistrationTrendCard extends StatelessWidget {
  const _RegistrationTrendCard();

  @override
  Widget build(BuildContext context) {
    // ORIGINAL DEMO CHART VALUES, NOT FIRESTORE DATA
    const heights = <double>[
      42,
      68,
      52,
      92,
      74,
      110,
      84,
    ];

    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color:
                AppColors.primaryDark.withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registration Activity',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Sample 7-day visualization',
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
                  color: AppColors.primary
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Text(
                  'DEMO',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // BAR CHART
          SizedBox(
            height: 157,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < heights.length; i++)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 23,
                          height: heights[i],
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFE6B84F),
                                AppColors.primary,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(7),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          days[i],
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Divider(
            color: AppColors.border,
            height: 1,
          ),

          const SizedBox(height: 13),

          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.info,
                size: 17,
              ),

              SizedBox(width: 8),

              Expanded(
                child: Text(
                  'This chart uses sample values. Actual '
                  'registration trends will require '
                  'registration data.',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.5,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ATTENDANCE BREAKUP CARD
// ============================================================

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: AppColors.success
                  .withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.pie_chart_outline_rounded,
              color: AppColors.success,
              size: 24,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrations Enabled Soon',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Attendance and attendee analytics '
                  'will appear when registration data '
                  'is available.',
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

// ============================================================
// ANALYTICS INFORMATION NOTICE
// ============================================================

class _AnalyticsInfoNotice extends StatelessWidget {
  const _AnalyticsInfoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.20),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.info,
            size: 20,
          ),

          SizedBox(width: 11),

          Expanded(
            child: Text(
              'Event counts are updated from your '
              'Firestore event records in real time. '
              'Registration and attendance statistics '
              'are not connected yet.',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 10.5,
                height: 1.6,
              ),
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

class _AnalyticsMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _AnalyticsMessage({
    required this.icon,
    required this.title,
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
            Icon(
              icon,
              size: 44,
              color: AppColors.error,
            ),

            const SizedBox(height: 14),

            Text(
              title,
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