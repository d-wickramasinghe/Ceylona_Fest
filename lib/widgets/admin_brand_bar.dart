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
  Size get preferredSize => Size.fromHeight(64 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        child: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDark,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: onBack == null
              ? null
              : IconButton(
                  onPressed: onBack, icon: const Icon(Icons.arrow_back)),
          titleSpacing: onBack == null ? 16 : 0,
          title: Row(children: [
            Image.asset('assets/images/ceylona_fest_logo.png',
                width: 92, height: 34, fit: BoxFit.contain),
            const SizedBox(width: 12),
            Flexible(
                child: Text(title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700))),
          ]),
          actions: [
            ...actions,
            const Padding(
                padding: EdgeInsets.only(right: 14),
                child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Text('AP',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark)))),
          ],
          bottom: bottom,
        ),
      );
}
