import 'package:flutter/widgets.dart';

class GameItem {
  const GameItem({
    required this.id,
    required this.imageAsset,
    required this.urduLabel,
    required this.matchWords,
    required this.rect,
  });

  final String id;
  final String imageAsset;
  final String urduLabel;
  final List<String> matchWords;
  final Rect rect;
}

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