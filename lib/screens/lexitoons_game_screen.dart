import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class LexitoonsGameScreen extends StatefulWidget {
  const LexitoonsGameScreen({Key? key}) : super(key: key);

  @override
  _LexitoonsGameScreenState createState() => _LexitoonsGameScreenState();
}

class _LexitoonsGameScreenState extends State<LexitoonsGameScreen>
    with TickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = '';

  // Words list matching bottom bar
  final Map<String, bool> _words = {
    'لیمو': false,  // Lemon
    'لکڑی': false,  // Wood
    'گلاب': false,  // Rose
    'لڑکی': false,  // Girl
  };

  bool _isLemonSelected = false;
  bool _isLemonInBasket = false;

  late AnimationController _zoomController;
  late AnimationController _basketController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _basketFlyAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    // Zoom-in effect on tap
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
    );

    // Flight path toward the bottom basket
    _basketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _basketFlyAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.2, 1.5),
    ).animate(
      CurvedAnimation(parent: _basketController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _basketController.dispose();
    super.dispose();
  }

  void _onLemonTapped() {
    if (_words['لیمو'] == true) return;

    setState(() {
      _isLemonSelected = !_isLemonSelected;
    });

    if (_isLemonSelected) {
      _zoomController.forward();
      _startListening('لیمو');
    } else {
      _zoomController.reverse();
      _stopListening();
    }
  }

  void _startListening(String targetWord) async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: 'ur_PK',
        onResult: (result) {
          setState(() {
            _spokenText = result.recognizedWords;
            if (_spokenText.contains(targetWord) ||
                _spokenText.contains('lemon') ||
                _spokenText.contains('لیمو')) {
              _onWordCorrect();
            }
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _onWordCorrect() {
    _stopListening();

    _basketController.forward().then((_) {
      setState(() {
        _isLemonInBasket = true;
        _words['لیمو'] = true;
        _isLemonSelected = false;
      });
      _basketController.reset();
      _zoomController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCEDC8),
      body: SafeArea(
        child: Column(
          children: [
            // 1. GAME CANVAS AREA
            Expanded(
              child: Stack(
                children: [
                  // Playground Background
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/background.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Character (Standing in middle path)
                  Align(
                    alignment: const Alignment(0.0, 0.35),
                    child: Image.asset(
                      'assets/images/character.png',
                      height: 110,
                    ),
                  ),

                  // Rose Bush (Placed on bottom-left flowers)
                  Align(
                    alignment: const Alignment(-0.85, 0.75),
                    child: Image.asset(
                      'assets/images/rose.png',
                      height: 80,
                    ),
                  ),

                  // Floating/Interactive Lemon
                  if (!_isLemonInBasket)
                    Align(
                      alignment: const Alignment(0.70, -0.10),
                      child: SlideTransition(
                        position: _basketFlyAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: GestureDetector(
                            onTap: _onLemonTapped,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: _isLemonSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.yellowAccent.withOpacity(0.9),
                                          blurRadius: 25,
                                          spreadRadius: 8,
                                        )
                                      ]
                                    : [],
                              ),
                              child: Image.asset(
                                'assets/images/Lemon.png',
                                width: 55,
                                height: 55,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Speech Mic Indicator
                  if (_isListening)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.mic, color: Colors.redAccent, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "بولیں: لیمو",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. BOTTOM PANEL (Basket + Urdu Words Checklist)
            Container(
              height: 70,
              color: const Color(0xFFDCEDC8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Basket Icon
                  Image.asset(
                    'assets/images/basket.png',
                    height: 50,
                  ),
                  const SizedBox(width: 20),

                  // Urdu Words List (RTL)
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _words.entries.map((entry) {
                          final isDone = entry.value;
                          return AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: isDone ? 0.25 : 1.0,
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black80,
                                decoration:
                                    isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}