import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class UrduNarrator {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setLanguage('ur-PK');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.05);
      await _tts.setVolume(1.0);
      debugPrint('[UrduNarrator] init ok');
    } catch (e, st) {
      debugPrint('[UrduNarrator] init FAILED: $e\n$st');
    }
    _ready = true; // don't retry forever even if setup failed
  }

  Future<void> speak(String text) async {
    await init();
    try {
      await _tts.stop();
      final result = await _tts.speak(text);
      debugPrint('[UrduNarrator] speak("$text") -> $result');
    } catch (e, st) {
      debugPrint('[UrduNarrator] speak FAILED: $e\n$st');
    }
  }

  Future<void> stop() => _tts.stop();
}