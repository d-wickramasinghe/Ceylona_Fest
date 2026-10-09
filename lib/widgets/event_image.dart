import 'package:flutter/material.dart';

class EventImage extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const EventImage({
    super.key,
    required this.url,
    this.width = double.infinity,
    this.height = 72,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = url?.trim() ?? '';
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xfffff3c4),
        borderRadius: borderRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? const Center(child: Icon(Icons.event, size: 28))
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.event, size: 28)),
            ),
    );
  }
}
