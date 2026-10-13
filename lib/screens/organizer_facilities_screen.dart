// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// import '../services/db.dart';

// class OrganizerFacilitiesScreen extends StatefulWidget {
//   final String eventId;
//   final String eventTitle;

//   const OrganizerFacilitiesScreen({
//     super.key,
//     required this.eventId,
//     required this.eventTitle,
//   });

//   @override
//   State<OrganizerFacilitiesScreen> createState() =>
//       _OrganizerFacilitiesScreenState();
// }

// class _OrganizerFacilitiesScreenState extends State<OrganizerFacilitiesScreen> {
//   Future<void> _editFacility(
//       _FacilityDefinition facility, String? current) async {
//     final note = TextEditingController(text: current);
//     final save = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: Text(facility.title),
//         content: TextField(
//           controller: note,
//           maxLines: 3,
//           decoration: const InputDecoration(
//             labelText: 'Facility details',
//             hintText: 'Add instructions, route, or availability',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: const Text('Cancel')),
//           FilledButton(
//               onPressed: () => Navigator.pop(dialogContext, true),
//               child: const Text('Save')),
//         ],
//       ),
//     );
//     if (save == true && note.text.trim().isNotEmpty) {
//       await Db.setFacility(widget.eventId, facility.key, note.text.trim());
//     }
//     note.dispose();
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AppBar(title: Text('Facilities • ${widget.eventTitle}')),
//         body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//           stream: Db.event(widget.eventId),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             final data = snapshot.data?.data() ?? <String, dynamic>{};
//             final facilities =
//                 Map<String, dynamic>.from(data['facilities'] as Map? ?? {});
//             return ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 const Text(
//                     'Facilities are independent event settings. Updating them does not send the event back for approval.'),
//                 const SizedBox(height: 16),
//                 for (final facility in _facilityDefinitions)
//                   Card(
//                     child: ListTile(
//                       leading: CircleAvatar(child: Icon(facility.icon)),
//                       title: Text(facility.title),
//                       subtitle: Text(facilities[facility.key]?.toString() ??
//                           'Not configured'),
//                       trailing: Wrap(
//                         children: [
//                           IconButton(
//                             tooltip: facilities.containsKey(facility.key)
//                                 ? 'Edit facility'
//                                 : 'Add facility',
//                             icon: Icon(facilities.containsKey(facility.key)
//                                 ? Icons.edit
//                                 : Icons.add),
//                             onPressed: () => _editFacility(
//                                 facility, facilities[facility.key]?.toString()),
//                           ),
//                           if (facilities.containsKey(facility.key))
//                             IconButton(
//                               tooltip: 'Delete facility',
//                               icon: const Icon(Icons.delete_outline),
//                               onPressed: () => Db.removeFacility(
//                                   widget.eventId, facility.key),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           },
//         ),
//       );
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


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/db.dart';
import '../theme/app_theme.dart';

class OrganizerFacilitiesScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const OrganizerFacilitiesScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  State<OrganizerFacilitiesScreen> createState() =>
      _OrganizerFacilitiesScreenState();
}

class _OrganizerFacilitiesScreenState
    extends State<OrganizerFacilitiesScreen> {

  // ============================================================
  // ORIGINAL BACKEND - ADD / EDIT FACILITY
  // ============================================================

  Future<void> _editFacility(
    _FacilityDefinition facility,
    String? current,
  ) async {
    final note = TextEditingController(text: current);

    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                facility.icon,
                color: AppColors.primary,
                size: 23,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                facility.title,
                style: Theme.of(dialogContext)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
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
                'FACILITY INFORMATION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.secondaryText,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: note,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Facility details',
                  hintText:
                      'Add instructions, route, or availability',
                  prefixIcon: const Icon(
                    Icons.edit_note_rounded,
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

        actionsPadding:
            const EdgeInsets.fromLTRB(20, 0, 20, 17),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),

          FilledButton.icon(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            icon: const Icon(
              Icons.check_rounded,
              size: 18,
            ),
            label: const Text('Save'),
          ),
        ],
      ),
    );

    // ORIGINAL VALIDATION AND DATABASE METHOD
    if (save == true && note.text.trim().isNotEmpty) {
      await Db.setFacility(
        widget.eventId,
        facility.key,
        note.text.trim(),
      );
    }

    note.dispose();
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
            // FIXED HEADER
            _FacilitiesHeader(
              eventTitle: widget.eventTitle,
              onBack: () => Navigator.pop(context),
            ),

            // ORIGINAL FIRESTORE STREAM
            Expanded(
              child: StreamBuilder<
                  DocumentSnapshot<Map<String, dynamic>>>(
                stream: Db.event(widget.eventId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Could not load facilities: ${snapshot.error}',
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

                  // ORIGINAL FACILITIES DATA
                  final data = snapshot.data?.data() ??
                      <String, dynamic>{};

                  final facilities =
                      Map<String, dynamic>.from(
                    data['facilities'] as Map? ?? {},
                  );

                  final configuredCount =
                      _facilityDefinitions.where((facility) {
                    return facilities.containsKey(facility.key);
                  }).length;

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      21,
                      16,
                      32,
                    ),
                    children: [
                      // ========================================
                      // SUMMARY CARD
                      // ========================================

                      _FacilitiesSummaryCard(
                        configured: configuredCount,
                        total: _facilityDefinitions.length,
                      ),

                      const SizedBox(height: 17),

                      // ========================================
                      // INFORMATION NOTICE
                      // ========================================

                      const _FacilityNotice(),

                      const SizedBox(height: 27),

                      // ========================================
                      // SECTION HEADER
                      // ========================================

                      _FacilitySectionHeader(
                        count: configuredCount,
                      ),

                      const SizedBox(height: 15),

                      // ========================================
                      // FACILITY CARDS
                      // ========================================

                      for (final facility in _facilityDefinitions)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 13,
                          ),
                          child: _FacilityCard(
                            facility: facility,
                            details:
                                facilities[facility.key]?.toString(),
                            configured:
                                facilities.containsKey(facility.key),

                            // ORIGINAL EDIT ACTION
                            onEdit: () => _editFacility(
                              facility,
                              facilities[facility.key]?.toString(),
                            ),

                            // ORIGINAL DELETE ACTION
                            onDelete: () => Db.removeFacility(
                              widget.eventId,
                              facility.key,
                            ),
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
// FACILITIES PAGE HEADER
// ============================================================

class _FacilitiesHeader extends StatelessWidget {
  final String eventTitle;
  final VoidCallback onBack;

  const _FacilitiesHeader({
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
          // TOP BAR
          Row(
            children: [
              Material(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.business_outlined,
                      color: AppColors.primary,
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'ORGANIZER',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.8,
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
                width: 22,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              const SizedBox(width: 8),

              const Text(
                'EVENT MANAGEMENT',
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
                  text: 'Facilities',
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
// SUMMARY CARD
// ============================================================

class _FacilitiesSummaryCard extends StatelessWidget {
  final int configured;
  final int total;

  const _FacilitiesSummaryCard({
    required this.configured,
    required this.total,
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
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.business_center_outlined,
              color: AppColors.primary,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EVENT AMENITIES',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.secondaryText,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$configured of $total Configured',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Manage your event facilities',
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
            size: 22,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFORMATION NOTICE
// ============================================================

class _FacilityNotice extends StatelessWidget {
  const _FacilityNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.22),
        ),
      ),

      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.info,
            size: 21,
          ),

          SizedBox(width: 11),

          Expanded(
            child: Text(
              'Facilities are independent event settings. '
              'Updating them does not send the event back '
              'for approval.',
              style: TextStyle(
                fontSize: 11,
                height: 1.6,
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
// SECTION HEADER
// ============================================================

class _FacilitySectionHeader extends StatelessWidget {
  final int count;

  const _FacilitySectionHeader({
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
          child: const Icon(
            Icons.category_outlined,
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
                'Available Facilities',
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
                'Add or update facility information',
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
// FACILITY CARD
// ============================================================

class _FacilityCard extends StatelessWidget {
  final _FacilityDefinition facility;
  final String? details;
  final bool configured;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FacilityCard({
    required this.facility,
    required this.details,
    required this.configured,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FACILITY HEADING
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.11,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  facility.icon,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  facility.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: configured
                      ? AppColors.success.withValues(
                          alpha: 0.11,
                        )
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  configured ? 'CONFIGURED' : 'NOT SET',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: configured
                        ? AppColors.success
                        : AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // FACILITY INFORMATION
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              details ?? 'Not configured',
              style: TextStyle(
                fontSize: 11,
                height: 1.6,
                fontWeight:
                    configured ? FontWeight.w500 : FontWeight.w400,
                color: configured
                    ? AppColors.primaryDark
                    : AppColors.secondaryText,
              ),
            ),
          ),

          const SizedBox(height: 14),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          const SizedBox(height: 12),

          // FACILITY ACTIONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: Icon(
                    configured
                        ? Icons.edit_outlined
                        : Icons.add_circle_outline_rounded,
                    size: 18,
                  ),
                  label: Text(
                    configured ? 'Edit Facility' : 'Add Facility',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    side: const BorderSide(
                      color: AppColors.border,
                    ),
                    minimumSize: const Size(0, 43),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),

              if (configured) ...[
                const SizedBox(width: 10),

                Tooltip(
                  message: 'Delete facility',
                  child: Material(
                    color: AppColors.error.withValues(
                      alpha: 0.09,
                    ),
                    borderRadius: BorderRadius.circular(11),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(11),
                      onTap: onDelete,
                      child: const SizedBox(
                        height: 43,
                        width: 43,
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                          size: 21,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FACILITY DEFINITION
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

// ORIGINAL FACILITY KEYS - UNCHANGED
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