import 'package:flutter/material.dart';

class ParkSceneScreen extends StatelessWidget {
  const ParkSceneScreen({Key? key}) : super(key: key);

  static const double figmaWidth = 700.0;
  static const double figmaHeight = 840.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: figmaWidth,
              height: figmaHeight,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // 1. Background Base
                  Positioned(
                    left: 0,
                    top: 0,
                    width: 700,
                    height: 840,
                    child: Image.asset(
                      'assets/images/background.png',
                      fit: BoxFit.fill,
                    ),
                  ),

                  // 2. Wooden Log (Shifted further left to X: 52 so it is noticeably moved)
                  Positioned(
                    left: 52,
                    top: 206,
                    width: 60,
                    height: 60,
                    child: Image.asset(
                      'assets/images/log.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  // 3. Swings (LOCKED)
                  Positioned(
                    left: 330,
                    top: 298,
                    width: 245.79,
                    height: 187.03,
                    child: Image.asset(
                      'assets/images/swing.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  // 4. Lemonade Stall (LOCKED)
                  Positioned(
                    left: 450,
                    top: 269,
                    width: 277,
                    height: 277,
                    child: Image.asset(
                      'assets/images/lemon_stall.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  // 5. Lemon Slice (LOCKED)
                  Positioned(
                    left: 576,
                    top: 441,
                    width: 79,
                    height: 72,
                    child: Image.asset(
                      'assets/images/lemon_slice.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  // 6. Girl Character (LOCKED)
                  Positioned(
                    left: 309,
                    top: 470,
                    width: 126,
                    height: 180,
                    child: Image.asset(
                      'assets/images/girl_3.png',
                      fit: BoxFit.fill,
                    ),
                  ),

                  // 7. Rose (LOCKED)
                  Positioned(
                    left: 43,
                    top: 570,
                    width: 88,
                    height: 88,
                    child: Image.asset(
                      'assets/images/rose.png',
                      fit: BoxFit.fill,
                    ),
                  ),

                  // 8. Bottom Green Banner & Urdu Words
                  Positioned(
                    left: 0,
                    top: 730,
                    width: 700,
                    height: 110,
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/images/green_rectangle.png',
                          width: 700,
                          height: 110,
                          fit: BoxFit.fill,
                        ),
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
                              
                              // Reduced Jhoola size significantly (height set to 40 instead of 55)
                              Image.asset('assets/images/word_jhoola.png', height: 40, fit: BoxFit.contain),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}