// // import 'package:flutter/material.dart';
// // import '../services/db.dart';

// // class AdminScreen extends StatelessWidget {
// //   const AdminScreen({super.key});
// //   @override
// //   Widget build(BuildContext context) => Scaffold(
// //         appBar: AppBar(title: const Text('Event Approvals')),
// //         body: StreamBuilder(
// //           stream: Db.pendingEvents(),
// //           builder: (c, s) {
// //             if (!s.hasData) return const Center(child: CircularProgressIndicator());
// //             if (s.data!.docs.isEmpty) return const Center(child: Text('No pending events'));
// //             return ListView(children: [
// //               for (final d in s.data!.docs)
// //                 Card(
// //                   child: ListTile(
// //                     title: Text(d['title']),
// //                     subtitle: Text('${d['date']} • ${d['location']}'),
// //                     trailing: Row(mainAxisSize: MainAxisSize.min, children: [
// //                       IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => Db.setStatus(d.id, 'approved')),
// //                       IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => Db.setStatus(d.id, 'rejected')),
// //                     ]),
// //                   ),
// //                 )
// //             ]);
// //           },
// //         ),
// //       );
// // }


// import 'package:flutter/material.dart';
// import '../services/db.dart';
// import '../theme/app_theme.dart';

// class AdminScreen extends StatelessWidget {
//   const AdminScreen({super.key});

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(
//           backgroundColor: AppColors.background,
//           elevation: 0,
//           title: const Text('Event Approvals'),
//         ),
//         body: StreamBuilder(
//           stream: Db.pendingEvents(),
//           builder: (c, s) {
//             if (!s.hasData) return const Center(child: CircularProgressIndicator());
//             if (s.data!.docs.isEmpty) return const Center(child: Text('No pending events'));
//             return ListView(
//               padding: const EdgeInsets.all(12),
//               children: [
//                 for (final d in s.data!.docs)
//                   Container(
//                     margin: const EdgeInsets.only(bottom: 10),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: AppColors.border),
//                     ),
//                     child: Row(children: [
//                       Expanded(
//                         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                           Text(d['title'] ?? '',
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.w600, fontSize: 15)),
//                           const SizedBox(height: 4),
//                           Text('${d['date'] ?? ''} • ${d['location'] ?? ''}',
//                               style: const TextStyle(
//                                   color: AppColors.secondaryText,
//                                   fontSize: 12)),
//                         ]),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.check_circle,
//                             color: AppColors.success),
//                         onPressed: () => Db.setStatus(d.id, 'approved'),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.cancel, color: AppColors.error),
//                         onPressed: () => Db.setStatus(d.id, 'rejected'),
//                       ),
//                     ]),
//                   ),
//               ],
//             );
//           },
//         ),
//       );
// }



import 'package:flutter/material.dart';

import '../services/db.dart';
import '../theme/app_theme.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // FIXED ADMIN HEADER
            // ==================================================
            const _AdminHeader(),

            // ==================================================
            // ORIGINAL FIRESTORE STREAM
            // ==================================================
            Expanded(
              child: StreamBuilder(
                stream: Db.pendingEvents(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _AdminErrorState(
                      message:
                          'Could not load pending events: ${snapshot.error}',
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      22,
                      16,
                      30,
                    ),
                    children: [
                      // Dashboard summary
                      _AdminSummaryCard(
                        count: docs.length,
                      ),

                      const SizedBox(height: 26),

                      // Section heading
                      _AdminSectionHeading(
                        count: docs.length,
                      ),

                      const SizedBox(height: 15),

                      // Pending event cards
                      if (docs.isEmpty)
                        const _NoPendingEvents()
                      else
                        for (final d in docs)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 14,
                            ),
                            child: _PendingEventCard(
                              data: d.data(),

                              // ORIGINAL BACKEND
                              onApprove: () =>
                                  Db.setStatus(
                                d.id,
                                'approved',
                              ),

                              onReject: () =>
                                  Db.setStatus(
                                d.id,
                                'rejected',
                              ),
                            ),
                          ),

                      const SizedBox(height: 10),
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
// ADMIN HEADER
// ============================================================

class _AdminHeader extends StatelessWidget {
  const _AdminHeader();

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
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP NAVIGATION
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
                      color: AppColors.primaryDark,
                      size: 17,
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
                      Icons.admin_panel_settings_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),

                    SizedBox(width: 6),

                    Text(
                      'ADMIN PANEL',
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

          // SMALL LABEL
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

          // MAIN TITLE
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
                  text: 'Approvals',
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
            'Review and manage submitted events.\n'
            'Keep the Ceylona community trusted.',
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
// ADMIN DASHBOARD SUMMARY
// ============================================================

class _AdminSummaryCard extends StatelessWidget {
  final int count;

  const _AdminSummaryCard({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.11,
        ),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.25,
          ),
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
              Icons.pending_actions_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'AWAITING REVIEW',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryText,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$count Pending ${count == 1 ? 'Event' : 'Events'}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Events waiting for admin approval',
                  style: TextStyle(
                    fontSize: 10,
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
// SECTION HEADING
// ============================================================

class _AdminSectionHeading extends StatelessWidget {
  final int count;

  const _AdminSectionHeading({
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
            Icons.fact_check_outlined,
            color: AppColors.primary,
            size: 21,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Pending Requests',
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
                'Review event submissions below',
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
            horizontal: 11,
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
// PENDING EVENT CARD
// ============================================================

class _PendingEventCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingEventCard({
    required this.data,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        data['title']?.toString() ?? 'Untitled Event';

    final date = data['date']?.toString() ?? '';
    final location = data['location']?.toString() ?? '';
    final category =
        data['category']?.toString() ?? 'Event';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
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

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CATEGORY AND STATUS
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: AppColors.warning,
                    ),

                    SizedBox(width: 5),

                    Text(
                      'PENDING',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // EVENT TITLE
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
          ),

          const SizedBox(height: 12),

          // DATE
          _EventDetailRow(
            icon: Icons.calendar_month_rounded,
            text: date,
          ),

          const SizedBox(height: 8),

          // LOCATION
          _EventDetailRow(
            icon: Icons.location_on_outlined,
            text: location,
          ),

          const SizedBox(height: 16),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          const SizedBox(height: 15),

          // APPROVE / REJECT BUTTONS
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 43,
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 43),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'Approve',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: SizedBox(
                  height: 43,
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      minimumSize: const Size(0, 43),
                      side: const BorderSide(
                        color: AppColors.error,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'Reject',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
// EVENT DETAIL ROW
// ============================================================

class _EventDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EventDetailRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 29,
          width: 29,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _NoPendingEvents extends StatelessWidget {
  const _NoPendingEvents();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              size: 43,
              color: AppColors.success,
            ),
          ),

          const SizedBox(height: 19),

          Text(
            'All Caught Up!',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
          ),

          const SizedBox(height: 9),

          const Text(
            'There are no pending events to review.\n'
            'New event submissions will appear here.',
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
// ERROR STATE
// ============================================================

class _AdminErrorState extends StatelessWidget {
  final String message;

  const _AdminErrorState({
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
              size: 44,
            ),

            const SizedBox(height: 14),

            Text(
              'Could Not Load Events',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
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
