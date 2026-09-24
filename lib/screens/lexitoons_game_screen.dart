import 'package:flutter/material.dart';
import '../controllers/park_game_controller.dart';
import '../models/game_item.dart';
import '../widgets/fixed_aspect_screen.dart';
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

  Rect _focusRect(Rect original) {
    const maxDimension = 260.0;
    final longer = original.width > original.height ? original.width : original.height;
    final scale = maxDimension / longer;
    const center = Offset(ParkSceneScreen.figmaWidth / 2, ParkSceneScreen.figmaHeight / 2);
    return Rect.fromCenter(center: center, width: original.width * scale, height: original.height * scale);
  }

  Widget _sceneItem(GameItem item) {
    return TappableSceneItem(
      item: item,
      isTappable: _controller.phase == GamePhase.awaitingTap &&
          _controller.currentItem?.id == item.id,
      isHidden: _controller.collectedIds.contains(item.id) ||
          _controller.activeItemId == item.id,
      onTap: () => _controller.onItemTapped(item.id),
    );
  }
  Widget _buildWordWidget(String itemId, String imageAsset, double height) {
    final isCollected = _controller.collectedIds.contains(itemId);
    final isCurrent = _controller.currentItem?.id == itemId;

    // 1. Faded when collected
    double opacity = 1.0;
    if (isCollected) {
      opacity = 0.25;
    }

    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isCurrent && !isCollected 
              ? Colors.yellow.withOpacity(0.3) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isCurrent && !isCollected
              ? Border.all(color: Colors.yellow, width: 2)
              : null,
        ),
        child: Image.asset(imageAsset, height: height, fit: BoxFit.contain),
      ),
    );
  }
  Widget? _buildActiveItemOverlay() {
    final id = _controller.activeItemId;
    final anim = _controller.activeAnim;
    if (id == null || anim == null) return null;
    final item = _item(id);
    final focus = _focusRect(item.rect);

    late final Rect start;
    late final Rect end;
    var showRing = true;
    switch (anim) {
      case ItemAnim.focusing:
        start = item.rect;
        end = focus;
        break;
      case ItemAnim.focused:
        start = focus;
        end = focus;
        break;
      case ItemAnim.returning:
        start = focus;
        end = item.rect;
        break;
      case ItemAnim.flying:
        start = focus;
        end = ParkSceneScreen.basketRect;
        showRing = false;
        break;
    }

    return _AnimatedItem(
      key: ValueKey('$id-$anim'),
      imageAsset: item.imageAsset,
      start: start,
      end: end,
      showRing: showRing,
      onComplete: _controller.onItemAnimComplete,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FixedAspectScreen(
      designWidth: ParkSceneScreen.figmaWidth,
      designHeight: ParkSceneScreen.figmaHeight,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final overlay = _buildActiveItemOverlay();
          return Stack(
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
                          _buildWordWidget('leemu', 'assets/images/word_leemu.png', 55),
                          _buildWordWidget('larki', 'assets/images/word_larki.png', 55),
                          _buildWordWidget('lakri', 'assets/images/word_lakri.png', 55),
                          _buildWordWidget('gulab', 'assets/images/word_gulaab.png', 55),
                          _buildWordWidget('jhoola', 'assets/images/word_jhoola.png', 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (overlay != null) overlay,

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
          );
        },
      ),
    );
  }
}

class _AnimatedItem extends StatelessWidget {
  const _AnimatedItem({
    super.key,
    required this.imageAsset,
    required this.start,
    required this.end,
    required this.showRing,
    required this.onComplete,
  });

  final String imageAsset;
  final Rect start;
  final Rect end;
  final bool showRing;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      onEnd: onComplete,
      builder: (context, t, child) {
        final rect = Rect.lerp(start, end, t)!;
        return Positioned(
          left: rect.left, top: rect.top, width: rect.width, height: rect.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: child!),
              if (showRing)
                const Positioned.fill(
                  child: IgnorePointer(child: CustomPaint(painter: FocusRingPainter())),
                ),
            ],
          ),
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