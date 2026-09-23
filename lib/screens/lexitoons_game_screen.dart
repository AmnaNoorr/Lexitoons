import 'package:flutter/material.dart';
import '../controllers/park_game_controller.dart';
import '../models/game_item.dart';
import '../widgets/tappable_scene_item.dart';

class ParkSceneScreen extends StatefulWidget {
  const ParkSceneScreen({super.key});

  static const double figmaWidth = 700.0;
  static const double figmaHeight = 840.0;
  static const Rect basketRect = Rect.fromLTWH(20, 742, 100, 85);

  @override
  State<ParkSceneScreen> createState() => _ParkSceneScreenState();
}

class _ParkSceneScreenState extends State<ParkSceneScreen> {
  late final List<GameItem> _items = buildParkSceneItems();
  late final ParkGameController _controller = ParkGameController(items: _items);
  bool _started = false;

  GameItem _item(String id) => _items.firstWhere((i) => i.id == id);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startGame() async {
    setState(() => _started = true);
    try {
      await _controller.start();
    } catch (e, st) {
      debugPrint('[Game] start() FAILED: $e\n$st');
    }
  }

  Widget _sceneItem(GameItem item) {
    return TappableSceneItem(
      item: item,
      isTappable: _controller.phase == GamePhase.awaitingTap &&
          _controller.currentItem?.id == item.id,
      isHighlighted: _controller.highlightedItemId == item.id,
      isHidden: _controller.collectedIds.contains(item.id) ||
          _controller.flyingItemId == item.id,
      onTap: () => _controller.onItemTapped(item.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: ParkSceneScreen.figmaWidth,
              height: ParkSceneScreen.figmaHeight,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      left: 0, top: 0, width: 700, height: 840,
                      child: Image.asset('assets/images/background.png', fit: BoxFit.fill),
                    ),
                    _sceneItem(_item('lakri')),
                    _sceneItem(_item('jhoola')),
                    Positioned(
                      left: 450, top: 269, width: 277, height: 277,
                      child: Image.asset('assets/images/lemon_stall.png', fit: BoxFit.contain),
                    ),
                    _sceneItem(_item('leemu')),
                    _sceneItem(_item('larki')),
                    _sceneItem(_item('gulab')),

                    // 8. Bottom Green Banner & Urdu Words (unchanged)
                    Positioned(
                      left: 0,
                      top: 730,
                      width: 700,
                      height: 110,
                      child: Stack(
                        children: [
                          Image.asset('assets/images/green_rectangle.png',
                              width: 700, height: 110, fit: BoxFit.fill),
                          Positioned(
                            left: 20,
                            top: 12,
                            width: 100,
                            height: 85,
                            child: Image.asset('assets/images/basket.png', fit: BoxFit.contain),
                          ),
                          Positioned(
                            left: 135,
                            right: 15,
                            top: 15,
                            bottom: 15,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              textDirection: TextDirection.rtl,
                              children: [
                                Image.asset('assets/images/word_leemu.png', height: 55, fit: BoxFit.contain),
                                Image.asset('assets/images/word_larki.png', height: 55, fit: BoxFit.contain),
                                Image.asset('assets/images/word_lakri.png', height: 55, fit: BoxFit.contain),
                                Image.asset('assets/images/word_gulaab.png', height: 55, fit: BoxFit.contain),
                                Image.asset('assets/images/word_jhoola.png', height: 40, fit: BoxFit.contain),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_controller.flyingItemId != null)
                      _FlyingItem(
                        imageAsset: _item(_controller.flyingItemId!).imageAsset,
                        start: _item(_controller.flyingItemId!).rect,
                        end: ParkSceneScreen.basketRect,
                        onComplete: _controller.onFlightAnimationComplete,
                      ),
                    
                    if (_started)
                      Positioned(
                        left: 16,
                        top: 16,
                        child: _ReplayButton(
                          enabled: _controller.phase != GamePhase.awaitingSpeech,
                          onTap: _controller.replayPrompt,
                        ),
                      ),

                    if (!_started)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black54,
                          child: Center(
                            child: ElevatedButton(
                              onPressed: _startGame,
                              child: const Text('شروع کریں'),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlyingItem extends StatelessWidget {
  const _FlyingItem({
    required this.imageAsset,
    required this.start,
    required this.end,
    required this.onComplete,
  });

  final String imageAsset;
  final Rect start;
  final Rect end;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInBack,
      onEnd: onComplete,
      builder: (context, t, child) {
        final rect = Rect.lerp(start, end, t)!;
        return Positioned(
          left: rect.left, top: rect.top, width: rect.width, height: rect.height,
          child: child!,
        );
      },
      child: Image.asset(imageAsset, fit: BoxFit.contain),
    );
  }
}

class _ReplayButton extends StatelessWidget {
  const _ReplayButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? const Color(0xFF4CAF50) : Colors.grey,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(Icons.volume_up, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}