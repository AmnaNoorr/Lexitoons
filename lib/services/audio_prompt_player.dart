import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class AudioPromptPlayer {
  final AudioPlayer _player = AudioPlayer();
  String? _lastKey;

  Future<void> play(String key) async {
    _lastKey = key;
    await _player.stop();
    final completer = Completer<void>();
    late final StreamSubscription sub;
    sub = _player.onPlayerComplete.listen((_) {
      if (!completer.isCompleted) completer.complete();
      sub.cancel();
    });
    await _player.play(AssetSource('audio/$key.wav'));
    await completer.future;
  }

  Future<void> replayLast() async {
    if (_lastKey != null) await play(_lastKey!);
  }

  Future<void> stop() => _player.stop();
}