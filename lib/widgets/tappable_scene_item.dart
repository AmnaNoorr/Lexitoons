import 'package:flutter/material.dart';
import '../models/game_item.dart';

/// Renders a scene object at its fixed position and listens for taps
/// while active. The "found" ring and enlarge effect are drawn by a
/// separate overlay (see ParkSceneScreen), never here — so they're
/// never hidden behind other artwork this item happens to overlap.
class TappableSceneItem extends StatelessWidget {
  const TappableSceneItem({
    super.key,
    required this.item,
    required this.isTappable,
    required this.isHidden,
    required this.onTap,
  });

  final GameItem item;
  final bool isTappable;
  final bool isHidden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isHidden) return const SizedBox.shrink();
    return Positioned(
      left: item.rect.left,
      top: item.rect.top,
      width: item.rect.width,
      height: item.rect.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isTappable ? onTap : null,
        child: Image.asset(item.imageAsset, fit: BoxFit.contain),
      ),
    );
  }
}

/// A ring drawn around whatever bounding box it's placed in.
class FocusRingPainter extends CustomPainter {
  const FocusRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawOval((Offset.zero & size).deflate(3), paint);
  }

  @override
  bool shouldRepaint(covariant FocusRingPainter oldDelegate) => false;
}