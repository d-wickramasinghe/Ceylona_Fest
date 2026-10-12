import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AdminBrandBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBack;
  final List<Widget> actions;

  const AdminBrandBar({
    super.key,
    required this.title,
    this.bottom,
    this.onBack,
    this.actions = const [],
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(64 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.background,
        child: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primaryDark,
          surfaceTintColor: Colors.transparent,
          elevation: 1,
          shadowColor: AppColors.border,
          leading: onBack == null
              ? null
              : IconButton(
                  onPressed: onBack, icon: const Icon(Icons.arrow_back)),
          titleSpacing: onBack == null ? 16 : 0,
          title: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.shield_outlined,
                  color: AppColors.primaryDark, size: 23),
            ),
            const SizedBox(width: 12),
            Flexible(
                child: Text(title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700))),
          ]),
          actions: [
            ...actions,
            const Padding(
                padding: EdgeInsets.only(right: 14),
                child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person_outline,
                        size: 18, color: AppColors.primaryDark))),
          ],
          bottom: bottom,
        ),
      );
}
