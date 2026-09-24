import 'package:flutter/material.dart';

/// Scales a fixed-size design canvas to fit any device screen while
/// preserving its exact proportions (no cropping, no redesigning).
/// Every screen in the app should be built on the same design canvas
/// and wrapped in this, so they all scale identically across devices.
class FixedAspectScreen extends StatelessWidget {
  const FixedAspectScreen({
    super.key,
    required this.designWidth,
    required this.designHeight,
    required this.child,
    this.backgroundColor = Colors.black,
  });

  final double designWidth;
  final double designHeight;
  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: designWidth,
              height: designHeight,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}