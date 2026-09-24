import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/game_item.dart';
import '../services/audio_prompt_player.dart';
import '../services/speech_recognizer_service.dart';

enum GamePhase { idle, prompting, awaitingTap, awaitingSpeech, finished }
enum ItemAnim { focusing, focused, returning, flying }

class ParkGameController extends ChangeNotifier {
  ParkGameController({
    required this.items,
    AudioPromptPlayer? audio,
    SpeechRecognizerService? speechService,
  })  : _audio = audio ?? AudioPromptPlayer(),
        _speech = speechService ?? SpeechRecognizerService();

  final List<GameItem> items;
  final AudioPromptPlayer _audio;
  final SpeechRecognizerService _speech;

  static const int _maxAttemptsPerItem = 2;
  static const List<String> _retryKeys = ['retry_1', 'retry_2', 'retry_3'];

  int _currentIndex = 0;
  GamePhase phase = GamePhase.idle;

  /// The one item currently away from its resting spot (mid-focus,
  /// mid-return, or flying to the basket), and what it's doing.
  String? activeItemId;
  ItemAnim? activeAnim;

  final Set<String> collectedIds = {};

  Completer<void>? _tapCompleter;
  Completer<void>? _animCompleter;
  bool _cancelled = false;

  GameItem? get currentItem =>
      _currentIndex < items.length ? items[_currentIndex] : null;

  Future<void> start() async {
    _cancelled = false;
    await _audio.play('intro');
    await _runRound();
  }

  Future<void> _runRound() async {
    for (_currentIndex = 0; _currentIndex < items.length; _currentIndex++) {
      if (_cancelled) return;
      final item = items[_currentIndex];

      phase = GamePhase.prompting;
      notifyListeners();
      await _audio.play('read_prompt');
      if (_cancelled) return;

      await _attemptItem(item);
      if (_cancelled) return;
    }

    phase = GamePhase.finished;
    notifyListeners();
    await _audio.play('outro');
  }

  /// Runs touch -> name -> (basket or back-in-place) for one item,
  /// retrying on a wrong answer until it succeeds or attempts run out.
  Future<void> _attemptItem(GameItem item) async {
    var attempt = 0;
    while (true) {
      attempt++;

      phase = GamePhase.awaitingTap;
      notifyListeners();
      await _waitForTap();
      if (_cancelled) return;

      await _runItemAnim(item, ItemAnim.focusing);
      activeAnim = ItemAnim.focused;
      notifyListeners();

      phase = GamePhase.awaitingSpeech;
      notifyListeners();
      final heard = await _speech.listenOnce();
      final correct = _speech.matches(heard, item.matchWords);
      final outOfAttempts = attempt >= _maxAttemptsPerItem;

      if (correct || outOfAttempts) {
        await _audio.play('praise_correct');
        await _runItemAnim(item, ItemAnim.flying);
        collectedIds.add(item.id);
        activeItemId = null;
        activeAnim = null;
        notifyListeners();
        return;
      }

      await _audio.play(_retryKeys[(attempt - 1) % _retryKeys.length]);
      await _runItemAnim(item, ItemAnim.returning);
      activeItemId = null;
      activeAnim = null;
      notifyListeners();
    }
  }

  Future<void> _runItemAnim(GameItem item, ItemAnim anim) async {
    activeItemId = item.id;
    activeAnim = anim;
    notifyListeners();
    _animCompleter = Completer<void>();
    await _animCompleter!.future;
  }

  Future<void> _waitForTap() {
    _tapCompleter = Completer<void>();
    return _tapCompleter!.future;
  }

  Future<void> replayPrompt() => _audio.replayLast();

  void onItemTapped(String id) {
    if (phase == GamePhase.awaitingTap &&
        currentItem?.id == id &&
        _tapCompleter != null &&
        !_tapCompleter!.isCompleted) {
      _tapCompleter!.complete();
    }
  }

  /// Called by the UI when the focus/return/flight animation finishes.
  void onItemAnimComplete() {
    if (_animCompleter != null && !_animCompleter!.isCompleted) {
      _animCompleter!.complete();
    }
  }

  @override
  void dispose() {
    _cancelled = true;
    _audio.stop();
    super.dispose();
  }
}