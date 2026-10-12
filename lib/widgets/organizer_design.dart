import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OrganizerPageIntro extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;

  const OrganizerPageIntro({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.icon = Icons.event_available_outlined,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primaryDark, size: 24),
          ),
          const SizedBox(width: 13),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(eyebrow.toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(title,
                    style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 19,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(description,
                    style: const TextStyle(
                        color: AppColors.secondaryText, height: 1.35)),
              ])),
        ]),
      );
}

class OrganizerStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const OrganizerStatusChip(
      {super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: .28))),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}
