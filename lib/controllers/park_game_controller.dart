import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/game_item.dart';
import '../services/speech_recognizer_service.dart';
import '../services/urdu_narrator.dart';

enum GamePhase { idle, prompting, awaitingTap, awaitingSpeech, celebrating, finished }

class ParkGameController extends ChangeNotifier {
  ParkGameController({
    required this.items,
    UrduNarrator? narrator,
    SpeechRecognizerService? speechService,
  })  : _narrator = narrator ?? UrduNarrator(),
        _speech = speechService ?? SpeechRecognizerService();

  final List<GameItem> items;
  final UrduNarrator _narrator;
  final SpeechRecognizerService _speech;

  static const int _maxAttemptsPerItem = 2;
  static const List<String> _encouragements = [
    'کوئی بات نہیں، دوبارہ کوشش کرو۔',
    'بہت اچھے، ایک بار پھر کوشش کرو۔',
    'کوئی مسئلہ نہیں، آہستہ آہستہ بولو۔',
  ];

  int _currentIndex = 0;
  GamePhase phase = GamePhase.idle;
  String? highlightedItemId;
  String? flyingItemId;
  String? _lastPrompt;
  final Set<String> collectedIds = {};

  Completer<void>? _tapCompleter;
  Completer<void>? _flightCompleter;
  bool _cancelled = false;

  GameItem? get currentItem =>
      _currentIndex < items.length ? items[_currentIndex] : null;

  Future<void> start() async {
    _cancelled = false;
    await _say(
      'چلو، پارک میں پانچ چیزیں ڈھونڈتے ہیں: '
      '${items.map((i) => i.urduLabel).join('، ')}۔',
    );
    await _runRound();
  }

  Future<void> _runRound() async {
    for (_currentIndex = 0; _currentIndex < items.length; _currentIndex++) {
      if (_cancelled) return;
      final item = items[_currentIndex];

      phase = GamePhase.prompting;
      notifyListeners();
      await _say('${item.urduLabel} کو ڈھونڈو اور اس پر انگلی رکھو۔');
      if (_cancelled) return;

      phase = GamePhase.awaitingTap;
      notifyListeners();
      await _waitForTap();
      if (_cancelled) return;

      highlightedItemId = item.id;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 600));

      await _askAndListen(item);
      if (_cancelled) return;
    }

    phase = GamePhase.finished;
    notifyListeners();
    await _say('شاباش! تم نے سب چیزیں ڈھونڈ لیں۔');
  }

  Future<void> _askAndListen(GameItem item) async {
    var attempt = 0;
    while (attempt < _maxAttemptsPerItem) {
      attempt++;
      phase = GamePhase.awaitingSpeech;
      notifyListeners();
      await _say('شاباش! اب بتاؤ، یہ کیا ہے؟');

      final heard = await _speech.listenOnce();
      if (_speech.matches(heard, item.matchWords)) {
        await _say('بہت خوب، بالکل ٹھیک!');
        await _sendToBasket(item);
        return;
      }
      if (attempt < _maxAttemptsPerItem) {
        await _say(_encouragements[(attempt - 1) % _encouragements.length]);
      }
    }
    // Don't trap the child on one item if pronunciation isn't recognized.
    await _sendToBasket(item);
  }

  Future<void> _sendToBasket(GameItem item) async {
    phase = GamePhase.celebrating;
    flyingItemId = item.id;
    highlightedItemId = null;
    notifyListeners();

    _flightCompleter = Completer<void>();
    await _flightCompleter!.future;

    collectedIds.add(item.id);
    flyingItemId = null;
    notifyListeners();
  }

  Future<void> _waitForTap() {
    _tapCompleter = Completer<void>();
    return _tapCompleter!.future;
  }

  Future<void> _say(String text) async {
    _lastPrompt = text;
    await _narrator.speak(text);
  }

  /// Repeats whatever was last narrated. The UI disables this while
  /// the mic is listening, so playback and recognition don't overlap.
  Future<void> replayPrompt() async {
    final text = _lastPrompt;
    if (text != null) await _narrator.speak(text);
  }

  void onItemTapped(String id) {
    if (phase == GamePhase.awaitingTap &&
        currentItem?.id == id &&
        _tapCompleter != null &&
        !_tapCompleter!.isCompleted) {
      _tapCompleter!.complete();
    }
  }

  void onFlightAnimationComplete() {
    if (_flightCompleter != null && !_flightCompleter!.isCompleted) {
      _flightCompleter!.complete();
    }
  }

  @override
  void dispose() {
    _cancelled = true;
    _narrator.stop();
    super.dispose();
  }
}