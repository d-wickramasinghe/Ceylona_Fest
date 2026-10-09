import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SeekerPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final List<Widget> actions;

  const SeekerPageHeader({
    super.key,
    required this.title,
    this.subtitle = '',
    this.onBack,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 132,
        child: Stack(children: [
          ClipPath(
              clipper: _SeekerHeaderClipper(),
              child: Container(color: AppColors.primary)),
          if (onBack != null)
            Positioned(
                top: 12,
                left: 12,
                child: IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back))),
          if (actions.isNotEmpty)
            Positioned(
                top: 12,
                right: 8,
                child: Row(children: actions)),
          Positioned(
              left: 22,
              bottom: 27,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w700)),
                    if (subtitle.isNotEmpty)
                      Text(subtitle, style: const TextStyle(fontSize: 11)),
                  ])),
        ]),
      );
}

class _SeekerHeaderClipper extends CustomClipper<ui.Path> {
  @override
  ui.Path getClip(Size size) {
    final path = ui.Path()..lineTo(0, size.height * .72);
    path.cubicTo(size.width * .25, size.height, size.width * .38,
        size.height * .52, size.width * .58, size.height * .72);
    path.cubicTo(size.width * .76, size.height * .9, size.width * .86,
        size.height * .5, size.width, size.height * .64);
    return path..lineTo(size.width, 0)..close();
  }

  @override
  bool shouldReclip(covariant _SeekerHeaderClipper oldClipper) => false;
}
