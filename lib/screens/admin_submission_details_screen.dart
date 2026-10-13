// import 'package:flutter/material.dart';

// import 'admin_review_checklist_screen.dart';
// import '../theme/app_theme.dart';
// import '../widgets/admin_brand_bar.dart';
// import '../widgets/admin_design.dart';

// class SubmissionDetailsScreen extends StatelessWidget {
//   const SubmissionDetailsScreen({super.key});

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AdminBrandBar(
//             title: 'Submission details',
//             onBack: () => Navigator.of(context).pop()),
//         body: SafeArea(
//           child: ListView(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//             children: [
//               const AdminPageIntro(
//                 eyebrow: 'Moderation',
//                 title: 'Review submission',
//                 description:
//                     'Check the event information carefully before making a decision.',
//                 icon: Icons.fact_check_outlined,
//               ),
//               const SizedBox(height: 16),
//               const _EventPoster(),
//               const SizedBox(height: 16),
//               const _DetailsCard(),
//               const SizedBox(height: 20),
//               const Text('Description', style: _SectionTitle.style),
//               const SizedBox(height: 8),
//               Text(
//                 'A vibrant celebration of Sri Lankan culture, bringing together '
//                 'music, dance, food, crafts, and community stories in the heart '
//                 'of Colombo.',
//                 style: TextStyle(
//                   color: Colors.grey.shade700,
//                   height: 1.5,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const _InfoSection(
//                 title: 'Organizer contact',
//                 items: [
//                   ('CONTACT PERSON', 'Nadeesha Perera'),
//                   ('EMAIL', 'nadeesha@ceylonarts.lk'),
//                   ('PHONE', '+94 77 234 5678'),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               const _InfoSection(
//                 title: 'Documents',
//                 items: [
//                   ('EVENT PROPOSAL', 'Colombo Cultural Festival Proposal.pdf'),
//                   (
//                     'VENUE CONFIRMATION',
//                     'Viharamahadevi Park Confirmation.pdf'
//                   ),
//                   ('UPLOADED', '18 September 2026 · 2:42 PM'),
//                 ],
//               ),
//               const SizedBox(height: 28),
//               SizedBox(
//                 height: 52,
//                 width: double.infinity,
//                 child: FilledButton(
//                   style: FilledButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     foregroundColor: AppColors.primaryDark,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   onPressed: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const ReviewChecklistScreen(),
//                     ),
//                   ),
//                   child: const Text(
//                     'Continue to Decision',
//                     style: TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
// }

// class _EventPoster extends StatelessWidget {
//   const _EventPoster();

//   @override
//   Widget build(BuildContext context) => ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: AspectRatio(
//           aspectRatio: 1.65,
//           child: DecoratedBox(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [AppColors.primary, Color(0xFFE6B84F)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Stack(
//               children: [
//                 Positioned(
//                   right: -30,
//                   top: -40,
//                   child: Icon(
//                     Icons.wb_sunny_outlined,
//                     color: AppColors.primaryDark.withValues(alpha: .14),
//                     size: 210,
//                   ),
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.all(22),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text(
//                         'SRI LANKA DAY',
//                         style: TextStyle(
//                           color: AppColors.primaryDark,
//                           fontSize: 25,
//                           fontWeight: FontWeight.w900,
//                           letterSpacing: 1.4,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         '24 OCTOBER 2026  ·  VIHARAMAHADEVI PARK',
//                         style: TextStyle(
//                           color: AppColors.primaryDark,
//                           fontSize: 11,
//                           fontWeight: FontWeight.w700,
//                           letterSpacing: .5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
// }

// class _DetailsCard extends StatelessWidget {
//   const _DetailsCard();

//   @override
//   Widget build(BuildContext context) => _AdminCard(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Colombo Cultural Festival',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
//             ),
//             const SizedBox(height: 20),
//             const _DetailRow(
//               label: 'ORGANIZER',
//               value: 'Nadeesha Perera · Ceylon Arts Collective',
//             ),
//             const _DetailRow(
//               label: 'CATEGORY',
//               value: 'Culture & Festival',
//             ),
//             const _DetailRow(
//               label: 'DATE / TIME',
//               value: '24 October 2026 · 10:00 AM-8:00 PM',
//             ),
//             const _DetailRow(
//               label: 'VENUE / LOCATION',
//               value: 'Viharamahadevi Park, Colombo 07',
//             ),
//             const _DetailRow(
//               label: 'SUBMITTED',
//               value: '18 September 2026 · 2:42 PM',
//               isLast: true,
//             ),
//           ],
//         ),
//       );
// }

// class _InfoSection extends StatelessWidget {
//   final String title;
//   final List<(String, String)> items;

//   const _InfoSection({required this.title, required this.items});

//   @override
//   Widget build(BuildContext context) => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: _SectionTitle.style),
//           const SizedBox(height: 10),
//           _AdminCard(
//             child: Column(
//               children: [
//                 for (var i = 0; i < items.length; i++)
//                   _DetailRow(
//                     label: items[i].$1,
//                     value: items[i].$2,
//                     isLast: i == items.length - 1,
//                   ),
//               ],
//             ),
//           ),
//         ],
//       );
// }

// class _DetailRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final bool isLast;

//   const _DetailRow({
//     required this.label,
//     required this.value,
//     this.isLast = false,
//   });

//   @override
//   Widget build(BuildContext context) => Padding(
//         padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 10,
//                 fontWeight: FontWeight.w800,
//                 letterSpacing: 1,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(value, style: const TextStyle(fontSize: 14)),
//           ],
//         ),
//       );
// }

// class _AdminCard extends StatelessWidget {
//   final Widget child;

//   const _AdminCard({required this.child});

//   @override
//   Widget build(BuildContext context) => Container(
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: AppColors.border),
//           boxShadow: const [
//             BoxShadow(
//               color: Color(0x12000000),
//               blurRadius: 12,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: child,
//       );
// }

// class _SectionTitle {
//   static const style = TextStyle(
//     fontSize: 17,
//     fontWeight: FontWeight.w800,
//     color: AppColors.primaryDark,
//   );
// }


import 'package:flutter/material.dart';

import 'admin_review_checklist_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/admin_brand_bar.dart';

class SubmissionDetailsScreen extends StatelessWidget {
  const SubmissionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AdminBrandBar(
        title: 'Submission details',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            // PAGE INTRO
            const _PageIntro(),
            const SizedBox(height: 20),

            // EVENT POSTER
            const _EventPoster(),
            const SizedBox(height: 20),

            // EVENT DETAILS
            const _SectionHeading(
              icon: Icons.event_note_outlined,
              title: 'Event Information',
              subtitle: 'Submitted event details',
            ),
            const SizedBox(height: 13),
            const _DetailsCard(),
            const SizedBox(height: 24),

            // EVENT DESCRIPTION
            const _SectionHeading(
              icon: Icons.article_outlined,
              title: 'Description',
              subtitle: 'About this event',
            ),
            const SizedBox(height: 13),
            const _AdminCard(
              child: Text(
                'A vibrant celebration of Sri Lankan culture, '
                'bringing together music, dance, food, crafts, '
                'and community stories in the heart of Colombo.',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  height: 1.75,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ORGANIZER CONTACT
            const _InfoSection(
              icon: Icons.contact_phone_outlined,
              title: 'Organizer Contact',
              subtitle: 'Contact information submitted',
              items: [
                (
                  'CONTACT PERSON',
                  'Nadeesha Perera',
                ),
                (
                  'EMAIL',
                  'nadeesha@ceylonarts.lk',
                ),
                (
                  'PHONE',
                  '+94 77 234 5678',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // DOCUMENTS
            const _InfoSection(
              icon: Icons.folder_open_outlined,
              title: 'Documents',
              subtitle: 'Supporting documents and submission info',
              items: [
                (
                  'EVENT PROPOSAL',
                  'Colombo Cultural Festival Proposal.pdf',
                ),
                (
                  'VENUE CONFIRMATION',
                  'Viharamahadevi Park Confirmation.pdf',
                ),
                (
                  'UPLOADED',
                  '18 September 2026 · 2:42 PM',
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ORIGINAL NAVIGATION - UNCHANGED
            SizedBox(
              height: 53,
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ReviewChecklistScreen(),
                  ),
                ),
                icon: const Icon(
                  Icons.fact_check_outlined,
                  size: 20,
                ),
                label: const Text(
                  'Continue to Decision',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Review the submitted details before continuing',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PAGE INTRO
// ============================================================

class _PageIntro extends StatelessWidget {
  const _PageIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              'ADMIN MODERATION',
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
                text: 'Review ',
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
                text: 'Submission',
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
          'Check the event information carefully\n'
          'before making a decision.',
          style: TextStyle(
            color: AppColors.secondaryText,
            height: 1.6,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PREMIUM EVENT POSTER
// ============================================================

class _EventPoster extends StatelessWidget {
  const _EventPoster();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(21),
      child: AspectRatio(
        aspectRatio: 1.65,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                Color(0xFFE6B84F),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -35,
                top: -45,
                child: Icon(
                  Icons.wb_sunny_outlined,
                  color: AppColors.primaryDark.withValues(
                    alpha: 0.12,
                  ),
                  size: 220,
                ),
              ),
              Positioned(
                left: -45,
                bottom: -90,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.14,
                      ),
                      width: 30,
                    ),
                  ),
                ),
              ),
              const Positioned(
                top: 16,
                left: 16,
                child: _PosterLabel(),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 45, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'SRI LANKA DAY',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '24 OCTOBER 2026  ·  VIHARAMAHADEVI PARK',
                      maxLines: 2,
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PosterLabel extends StatelessWidget {
  const _PosterLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.celebration_outlined,
            size: 15,
            color: AppColors.primary,
          ),
          SizedBox(width: 6),
          Text(
            'CULTURAL FESTIVAL',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
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
            size: 20,
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
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 10,
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
// EVENT INFORMATION CARD
// ============================================================

class _DetailsCard extends StatelessWidget {
  const _DetailsCard();

  @override
  Widget build(BuildContext context) {
    return _AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.event_available_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'EVENT SUBMISSION',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Colombo Cultural Festival',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
          ),
          const SizedBox(height: 18),
          const Divider(
            color: AppColors.border,
            height: 1,
          ),
          const SizedBox(height: 18),
          const _DetailRow(
            icon: Icons.person_outline_rounded,
            label: 'ORGANIZER',
            value: 'Nadeesha Perera · Ceylon Arts Collective',
          ),
          const _DetailRow(
            icon: Icons.category_outlined,
            label: 'CATEGORY',
            value: 'Culture & Festival',
          ),
          const _DetailRow(
            icon: Icons.calendar_month_outlined,
            label: 'DATE / TIME',
            value: '24 October 2026 · 10:00 AM-8:00 PM',
          ),
          const _DetailRow(
            icon: Icons.location_on_outlined,
            label: 'VENUE / LOCATION',
            value: 'Viharamahadevi Park, Colombo 07',
          ),
          const _DetailRow(
            icon: Icons.schedule_rounded,
            label: 'SUBMITTED',
            value: '18 September 2026 · 2:42 PM',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CONTACT / DOCUMENTS SECTION
// ============================================================

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<(String, String)> items;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  IconData _iconFor(String label) {
    switch (label) {
      case 'CONTACT PERSON':
        return Icons.person_outline_rounded;
      case 'EMAIL':
        return Icons.email_outlined;
      case 'PHONE':
        return Icons.phone_outlined;
      case 'EVENT PROPOSAL':
      case 'VENUE CONFIRMATION':
        return Icons.description_outlined;
      case 'UPLOADED':
        return Icons.upload_file_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeading(
          icon: icon,
          title: title,
          subtitle: subtitle,
        ),
        const SizedBox(height: 13),
        _AdminCard(
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++)
                _DetailRow(
                  icon: _iconFor(items[i].$1),
                  label: items[i].$1,
                  value: items[i].$2,
                  isLast: i == items.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DETAIL ROW
// ============================================================

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 17,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
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
// SHARED WHITE CARD
// ============================================================

class _AdminCard extends StatelessWidget {
  final Widget child;

  const _AdminCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.035),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}