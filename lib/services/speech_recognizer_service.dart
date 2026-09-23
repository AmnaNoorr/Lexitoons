import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechAttempt {
  const SpeechAttempt(this.text, this.confidence);
  final String text;
  final double confidence;
}

class SpeechRecognizerService {
  final SpeechToText _stt = SpeechToText();
  bool _ready = false;

  Future<bool> _ensureReady() async {
    if (_ready) return true;
    final micStatus = await Permission.microphone.request();
    debugPrint('[Speech] mic permission: $micStatus');
    if (!micStatus.isGranted) return false;
    _ready = await _stt.initialize(
      onError: (e) => debugPrint('[Speech] stt error: $e'),
      onStatus: (s) => debugPrint('[Speech] stt status: $s'),
    );
    debugPrint('[Speech] initialize -> $_ready');
    return _ready;
  }

  Future<SpeechAttempt> listenOnce({Duration timeout = const Duration(seconds: 6)}) async {
    if (!await _ensureReady()) return const SpeechAttempt('', 0);

    final completer = Completer<SpeechAttempt>();
    var last = const SpeechAttempt('', 0);

    await _stt.listen(
      localeId: 'ur_PK',
      onResult: (result) {
        last = SpeechAttempt(result.recognizedWords, result.confidence);
        debugPrint('[Speech] heard "${result.recognizedWords}" final=${result.finalResult} conf=${result.confidence}');
        if (result.finalResult && !completer.isCompleted) {
          completer.complete(last);
        }
      },
      listenFor: timeout,
      pauseFor: const Duration(seconds: 3),
    );

    final heard = await completer.future.timeout(
      timeout + const Duration(seconds: 1),
      onTimeout: () {
        debugPrint('[Speech] listen timed out with "${last.text}"');
        return last;
      },
    );
    if (_stt.isListening) await _stt.stop();
    return heard;
  }

  bool matches(SpeechAttempt attempt, List<String> expected) {
    final normalized = attempt.text.trim();
    if (normalized.isEmpty) return false;
    final hasWord = expected.any((word) => normalized.contains(word));
    if (!hasWord) return false;
    if (attempt.confidence <= 0) return true;
    return attempt.confidence >= 0.35;
  }
}