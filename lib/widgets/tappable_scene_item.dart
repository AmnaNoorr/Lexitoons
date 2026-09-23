import 'package:flutter/material.dart';
import '../models/game_item.dart';

/// Renders a scene object at its fixed position, listens for taps while
/// active, and shows a ring once the child has correctly found it.
class TappableSceneItem extends StatelessWidget {
  const TappableSceneItem({
    super.key,
    required this.item,
    required this.isTappable,
    required this.isHighlighted,
    required this.isHidden,
    required this.onTap,
  });

  final GameItem item;
  final bool isTappable;
  final bool isHighlighted;
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(item.imageAsset, fit: BoxFit.contain),
            if (isHighlighted)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _RingPainter()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawOval((Offset.zero & size).deflate(2), paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => false;
}