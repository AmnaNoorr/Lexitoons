import 'package:flutter/widgets.dart';

/// A single object in the park scene the child must find and name.
class GameItem {
  const GameItem({
    required this.id,
    required this.imageAsset,
    required this.urduLabel,
    required this.matchWords,
    required this.rect,
  });

  /// Stable identifier used internally, e.g. 'leemu'.
  final String id;

  /// Asset shown in the scene.
  final String imageAsset;

  /// Urdu word spoken by the narrator for this item.
  final String urduLabel;

  /// Acceptable spoken answers matched against speech-to-text output.
  final List<String> matchWords;

  /// Position and size inside the 700x840 scene canvas (see
  /// ParkSceneScreen.figmaWidth/figmaHeight).
  final Rect rect;
}

/// The five findable objects, in the same order as the word banner.
List<GameItem> buildParkSceneItems() => const [
      GameItem(
        id: 'leemu',
        imageAsset: 'assets/images/lemon_slice.png',
        urduLabel: 'لیموں',
        matchWords: ['لیموں'],
        rect: Rect.fromLTWH(576, 441, 79, 72),
      ),
      GameItem(
        id: 'larki',
        imageAsset: 'assets/images/girl_3.png',
        urduLabel: 'لڑکی',
        matchWords: ['لڑکی'],
        rect: Rect.fromLTWH(309, 470, 126, 180),
      ),
      GameItem(
        id: 'lakri',
        imageAsset: 'assets/images/log.png',
        urduLabel: 'لکڑی',
        matchWords: ['لکڑی'],
        rect: Rect.fromLTWH(52, 206, 60, 60),
      ),
      GameItem(
        id: 'gulab',
        imageAsset: 'assets/images/rose.png',
        urduLabel: 'گلاب',
        matchWords: ['گلاب'],
        rect: Rect.fromLTWH(43, 570, 88, 88),
      ),
      GameItem(
        id: 'jhoola',
        imageAsset: 'assets/images/swing.png',
        urduLabel: 'جھولا',
        matchWords: ['جھولا', 'جھولے'],
        rect: Rect.fromLTWH(330, 298, 245.79, 187.03),
      ),
    ];