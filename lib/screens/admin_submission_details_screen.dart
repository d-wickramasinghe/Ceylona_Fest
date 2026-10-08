import 'package:flutter/material.dart';

import 'admin_review_checklist_screen.dart';
import '../theme/app_theme.dart';

class SubmissionDetailsScreen extends StatelessWidget {
  const SubmissionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          leading: const BackButton(),
          title: const Text('Submission Details'),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: _StatusPill(
                  label: 'Pending Review', color: AppColors.warning),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const _EventPoster(),
              const SizedBox(height: 16),
              const _DetailsCard(),
              const SizedBox(height: 20),
              const Text('Description', style: _SectionTitle.style),
              const SizedBox(height: 8),
              Text(
                'A vibrant celebration of Sri Lankan culture, bringing together '
                'music, dance, food, crafts, and community stories in the heart '
                'of Colombo.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              const _InfoSection(
                title: 'Organizer contact',
                items: [
                  ('CONTACT PERSON', 'Nadeesha Perera'),
                  ('EMAIL', 'nadeesha@ceylonarts.lk'),
                  ('PHONE', '+94 77 234 5678'),
                ],
              ),
              const SizedBox(height: 20),
              const _InfoSection(
                title: 'Documents',
                items: [
                  ('EVENT PROPOSAL', 'Colombo Cultural Festival Proposal.pdf'),
                  ('VENUE CONFIRMATION', 'Viharamahadevi Park Confirmation.pdf'),
                  ('UPLOADED', '18 September 2026 · 2:42 PM'),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReviewChecklistScreen(),
                    ),
                  ),
                  child: const Text(
                    'Continue to Decision',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _EventPoster extends StatelessWidget {
  const _EventPoster();

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1.65,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B1712), Color(0xFF9F6E18)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  top: -40,
                  child: Icon(
                    Icons.wb_sunny_outlined,
                    color: Colors.white.withValues(alpha: .16),
                    size: 210,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'SRI LANKA DAY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '24 OCTOBER 2026  ·  VIHARAMAHADEVI PARK',
                        style: TextStyle(
                          color: Color(0xFFFFD76A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .5,
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

class _DetailsCard extends StatelessWidget {
  const _DetailsCard();

  @override
  Widget build(BuildContext context) => _AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Colombo Cultural Festival',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            const _DetailRow(
              label: 'ORGANIZER',
              value: 'Nadeesha Perera · Ceylon Arts Collective',
            ),
            const _DetailRow(
              label: 'CATEGORY',
              value: 'Culture & Festival',
            ),
            const _DetailRow(
              label: 'DATE / TIME',
              value: '24 October 2026 · 10:00 AM-8:00 PM',
            ),
            const _DetailRow(
              label: 'VENUE / LOCATION',
              value: 'Viharamahadevi Park, Colombo 07',
            ),
            const _DetailRow(
              label: 'SUBMITTED',
              value: '18 September 2026 · 2:42 PM',
              isLast: true,
            ),
          ],
        ),
      );
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<(String, String)> items;

  const _InfoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _SectionTitle.style),
          const SizedBox(height: 10),
          _AdminCard(
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++)
                  _DetailRow(
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 14)),
          ],
        ),
      );
}

class _AdminCard extends StatelessWidget {
  final Widget child;

  const _AdminCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: child,
      );
}

class _SectionTitle {
  static const style = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryDark,
  );
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .2),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}
