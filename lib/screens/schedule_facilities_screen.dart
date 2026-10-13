// import 'package:flutter/material.dart';
// import '../services/db.dart';
// import '../widgets/ceylona_bottom_navigation.dart';
// import '../theme/app_theme.dart';

// class ScheduleFacilitiesScreen extends StatelessWidget {
//   final String eventId;
//   const ScheduleFacilitiesScreen({super.key, required this.eventId});

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         bottomNavigationBar: const CeylonaBottomNavigation(selectedIndex: 2),
//         body: StreamBuilder(
//           stream: Db.event(eventId),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (!snapshot.data!.exists) {
//               return const Center(child: Text('Event not found'));
//             }
//             final data = snapshot.data!.data() ?? <String, dynamic>{};
//             final agenda = (data['agenda'] as List?)
//                     ?.whereType<Map>()
//                     .map((item) => Map<String, dynamic>.from(item))
//                     .toList() ??
//                 [];
//             final facilities =
//                 Map<String, dynamic>.from(data['facilities'] as Map? ?? {});
//             return ListView(
//                 padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
//                 children: [
//                   _ScheduleHeader(
//                       title: 'Schedule & Facilities',
//                       eventTitle: data['title']?.toString() ?? 'Event',
//                       onBack: () => Navigator.pop(context)),
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
//                     child: Column(children: [
//                   _ScheduleSummary(
//                       date: '${data['date'] ?? ''} ${data['time'] ?? ''}',
//                       location: data['location']?.toString() ?? ''),
//                   const SizedBox(height: 18),
//                   const Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text('Event Timeline',
//                       style:
//                           TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
//                   ),
//                   const SizedBox(height: 10),
//                   if (agenda.isEmpty)
//                     const Text('No schedule added yet.',
//                         style:
//                             TextStyle(fontSize: 11, color: Color(0xff667085))),
//                   for (final item in agenda)
//                     _TimelineRow(
//                         time: item['time']?.toString() ?? '',
//                         activity: item['activity']?.toString() ?? ''),
//                   const SizedBox(height: 24),
//                   const Text('On-Site Facilities',
//                       style:
//                           TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
//                   const SizedBox(height: 8),
//                   for (final facility in _facilityDefinitions)
//                     if (facilities[facility.key]?.toString().isNotEmpty == true)
//                       _FacilityRow(
//                           icon: facility.icon,
//                           title: facility.title,
//                           note: facilities[facility.key].toString()),
//                   if (facilities.isEmpty)
//                     const Text('No facilities added yet.',
//                         style:
//                             TextStyle(fontSize: 11, color: Color(0xff667085))),
//                     ]),
//                   ),
//                 ]);
//           },
//         ),
//       );
// }

// class _ScheduleHeader extends StatelessWidget {
//   final String title;
//   final String eventTitle;
//   final VoidCallback onBack;
//   const _ScheduleHeader(
//       {required this.title, required this.eventTitle, required this.onBack});

//   @override
//   Widget build(BuildContext context) => SizedBox(
//         height: 128,
//         child: Stack(children: [
//           ClipPath(
//               clipper: _ScheduleClipper(),
//               child: Container(color: AppColors.primary)),
//           Positioned(
//               top: 14,
//               left: 12,
//               child: IconButton(
//                   onPressed: onBack, icon: const Icon(Icons.arrow_back))),
//           Positioned(
//               left: 20,
//               bottom: 27,
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text(title,
//                     style: const TextStyle(
//                         fontSize: 21, fontWeight: FontWeight.w700)),
//                 Text(eventTitle, style: const TextStyle(fontSize: 11)),
//               ])),
//         ]),
//       );
// }

// class _ScheduleClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final path = Path()..lineTo(0, size.height * .72);
//     path.cubicTo(size.width * .25, size.height, size.width * .38,
//         size.height * .52, size.width * .58, size.height * .72);
//     path.cubicTo(size.width * .76, size.height * .9, size.width * .86,
//         size.height * .5, size.width, size.height * .64);
//     return path..lineTo(size.width, 0)..close();
//   }

//   @override
//   bool shouldReclip(covariant _ScheduleClipper oldClipper) => false;
// }

// class _ScheduleSummary extends StatelessWidget {
//   final String date;
//   final String location;
//   const _ScheduleSummary({required this.date, required this.location});

//   @override
//   Widget build(BuildContext context) => Column(children: [
//         _ScheduleSummaryRow(icon: Icons.calendar_month_outlined, text: date),
//         _ScheduleSummaryRow(icon: Icons.location_on_outlined, text: location),
//       ]);
// }

// class _ScheduleSummaryRow extends StatelessWidget {
//   final IconData icon;
//   final String text;
//   const _ScheduleSummaryRow({required this.icon, required this.text});

//   @override
//   Widget build(BuildContext context) => Card(
//         child: ListTile(
//             leading: CircleAvatar(
//                 backgroundColor: AppColors.primary.withValues(alpha: .14),
//                 child: Icon(icon, color: AppColors.primaryDark, size: 18)),
//             title: Text(text,
//                 style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
//       );
// }

// class _TimelineRow extends StatelessWidget {
//   final String time;
//   final String activity;
//   const _TimelineRow({required this.time, required this.activity});
//   @override
//   Widget build(BuildContext context) => Padding(
//       padding: const EdgeInsets.only(bottom: 14),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         SizedBox(
//             width: 66,
//             child: Text(time,
//                 style: const TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xff667085)))),
//         Expanded(
//             child: Text(activity,
//                 style: const TextStyle(fontSize: 11, color: Color(0xff172033))))
//       ]));
// }

// class _FacilityDefinition {
//   final String key;
//   final IconData icon;
//   final String title;
//   const _FacilityDefinition(this.key, this.icon, this.title);
// }

// const _facilityDefinitions = [
//   _FacilityDefinition('parking', Icons.local_parking, 'Parking'),
//   _FacilityDefinition('transport', Icons.directions_bus, 'Public Transport'),
//   _FacilityDefinition('food', Icons.restaurant, 'Food & Drinks'),
//   _FacilityDefinition('restrooms', Icons.wc, 'Restrooms'),
//   _FacilityDefinition('firstAid', Icons.medical_services, 'First Aid'),
// ];

// class _FacilityRow extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String note;
//   const _FacilityRow(
//       {required this.icon, required this.title, required this.note});
//   @override
//   Widget build(BuildContext context) => Padding(
//       padding: const EdgeInsets.only(bottom: 14),
//       child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         CircleAvatar(
//             radius: 18,
//             backgroundColor: const Color(0xffe5e7eb),
//             child: Icon(icon, size: 17, color: const Color(0xff667085))),
//         const SizedBox(width: 10),
//         Expanded(
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(title,
//               style:
//                   const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
//           const SizedBox(height: 3),
//           Text(note,
//               style: const TextStyle(fontSize: 10, color: Color(0xff667085)))
//         ]))
//       ]));
// }



import 'package:flutter/material.dart';

import '../services/db.dart';
import '../widgets/ceylona_bottom_navigation.dart';
import '../theme/app_theme.dart';

class ScheduleFacilitiesScreen extends StatelessWidget {
  final String eventId;

  const ScheduleFacilitiesScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ORIGINAL BOTTOM NAVIGATION
      bottomNavigationBar:
          const CeylonaBottomNavigation(selectedIndex: 2),

      body: SafeArea(
        child: StreamBuilder(
          // ORIGINAL FIRESTORE STREAM
          stream: Db.event(eventId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _PageMessage(
                icon: Icons.error_outline_rounded,
                title: 'Could Not Load Event',
                message: '${snapshot.error}',
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (!snapshot.data!.exists) {
              return const _PageMessage(
                icon: Icons.event_busy_outlined,
                title: 'Event Not Found',
                message: 'This event is no longer available.',
              );
            }

            // ORIGINAL EVENT DATA
            final data =
                snapshot.data!.data() ?? <String, dynamic>{};

            final agenda = (data['agenda'] as List?)
                    ?.whereType<Map>()
                    .map(
                      (item) => Map<String, dynamic>.from(item),
                    )
                    .toList() ??
                [];

            final facilities = Map<String, dynamic>.from(
              data['facilities'] as Map? ?? {},
            );

            // DISPLAY COUNTS ONLY
            final availableFacilities = _facilityDefinitions
                .where(
                  (facility) =>
                      facilities[facility.key]
                          ?.toString()
                          .isNotEmpty ==
                      true,
                )
                .toList();

            return Column(
              children: [
                // FIXED MODERN HEADER
                _ScheduleHeader(
                  eventTitle:
                      data['title']?.toString() ?? 'Event',
                  onBack: () => Navigator.pop(context),
                ),

                // SCROLLABLE CONTENT
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      21,
                      16,
                      30,
                    ),
                    children: [
                      // ======================================
                      // EVENT SUMMARY
                      // ======================================

                      _ScheduleSummary(
                        date:
                            '${data['date'] ?? ''} ${data['time'] ?? ''}',
                        location:
                            data['location']?.toString() ?? '',
                      ),

                      const SizedBox(height: 25),

                      // ======================================
                      // TIMELINE SECTION
                      // ======================================

                      _SectionHeading(
                        icon: Icons.view_timeline_outlined,
                        title: 'Event Timeline',
                        subtitle: 'Explore the event schedule',
                        count: agenda.length,
                      ),

                      const SizedBox(height: 15),

                      if (agenda.isEmpty)
                        const _EmptySection(
                          icon: Icons.event_note_outlined,
                          title: 'No Schedule Added Yet',
                          message:
                              'The organizer has not added an event timeline.',
                        )
                      else
                        _TimelineCard(
                          agenda: agenda,
                        ),

                      const SizedBox(height: 27),

                      // ======================================
                      // FACILITIES SECTION
                      // ======================================

                      _SectionHeading(
                        icon: Icons.business_outlined,
                        title: 'On-Site Facilities',
                        subtitle:
                            'Helpful amenities at the venue',
                        count: availableFacilities.length,
                      ),

                      const SizedBox(height: 15),

                      if (availableFacilities.isEmpty)
                        const _EmptySection(
                          icon: Icons.business_center_outlined,
                          title: 'No Facilities Added Yet',
                          message:
                              'Facility information will appear here when available.',
                        )
                      else
                        for (final facility
                            in availableFacilities)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: _FacilityRow(
                              icon: facility.icon,
                              title: facility.title,
                              note: facilities[facility.key]
                                  .toString(),
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
    );
  }
}

// ============================================================
// MODERN PAGE HEADER
// ============================================================

class _ScheduleHeader extends StatelessWidget {
  final String eventTitle;
  final VoidCallback onBack;

  const _ScheduleHeader({
    required this.eventTitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        19,
        16,
        19,
        23,
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
          Row(
            children: [
              Material(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: onBack,
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
                  color: AppColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(20),
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
                      'EVENT GUIDE',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.7,
                        fontWeight: FontWeight.w700,
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
                height: 3,
                width: 22,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(width: 8),

              const Text(
                'PLAN YOUR EXPERIENCE',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Schedule ',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),
                TextSpan(
                  text: '& Facilities',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            eventTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
// EVENT SUMMARY
// ============================================================

class _ScheduleSummary extends StatelessWidget {
  final String date;
  final String location;

  const _ScheduleSummary({
    required this.date,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.calendar_month_rounded,
            label: 'EVENT DATE & TIME',
            value: date.trim(),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Divider(
              color: AppColors.border,
              height: 1,
            ),
          ),

          _SummaryRow(
            icon: Icons.location_on_rounded,
            label: 'EVENT LOCATION',
            value: location,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 43,
          width: 43,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
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
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.secondaryText,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  color: AppColors.primaryDark,
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
// SECTION HEADING
// ============================================================

class _SectionHeading extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int count;

  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.12,
            ),
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
            color: AppColors.primary.withValues(alpha: 0.12),
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
// EVENT TIMELINE CARD
// ============================================================

class _TimelineCard extends StatelessWidget {
  final List<Map<String, dynamic>> agenda;

  const _TimelineCard({
    required this.agenda,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 18, 15, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(
              alpha: 0.035,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < agenda.length; i++)
            _TimelineRow(
              number: i + 1,
              isLast: i == agenda.length - 1,
              time: agenda[i]['time']?.toString() ?? '',
              activity:
                  agenda[i]['activity']?.toString() ?? '',
            ),
        ],
      ),
    );
  }
}

// ============================================================
// TIMELINE ROW
// ============================================================

class _TimelineRow extends StatelessWidget {
  final int number;
  final bool isLast;
  final String time;
  final String activity;

  const _TimelineRow({
    required this.number,
    required this.isLast,
    required this.time,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // VERTICAL TIMELINE INDICATOR
          SizedBox(
            width: 29,
            child: Column(
              children: [
                Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
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

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    activity,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: AppColors.primaryDark,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FACILITY DEFINITIONS - ORIGINAL KEYS
// ============================================================

class _FacilityDefinition {
  final String key;
  final IconData icon;
  final String title;

  const _FacilityDefinition(
    this.key,
    this.icon,
    this.title,
  );
}

const _facilityDefinitions = [
  _FacilityDefinition(
    'parking',
    Icons.local_parking_rounded,
    'Parking',
  ),
  _FacilityDefinition(
    'transport',
    Icons.directions_bus_rounded,
    'Public Transport',
  ),
  _FacilityDefinition(
    'food',
    Icons.restaurant_rounded,
    'Food & Drinks',
  ),
  _FacilityDefinition(
    'restrooms',
    Icons.wc_rounded,
    'Restrooms',
  ),
  _FacilityDefinition(
    'firstAid',
    Icons.medical_services_rounded,
    'First Aid',
  ),
];

// ============================================================
// FACILITY CARD
// ============================================================

class _FacilityRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String note;

  const _FacilityRow({
    required this.icon,
    required this.title,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(
              alpha: 0.03,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.11,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
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
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                ),

                const SizedBox(height: 7),

                Text(
                  note,
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
      ),
    );
  }
}

// ============================================================
// EMPTY SECTION
// ============================================================

class _EmptySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptySection({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 31,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.11,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 34,
            ),
          ),

          const SizedBox(height: 15),

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
    );
  }
}

// ============================================================
// ERROR / NOT FOUND STATE
// ============================================================

class _PageMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _PageMessage({
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
              color: AppColors.primary,
              size: 42,
            ),

            const SizedBox(height: 13),

            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.secondaryText,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}