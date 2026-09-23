import 'package:flutter/material.dart';
import 'screens/lexitoons_game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LexitoonsApp());
}

class LexitoonsApp extends StatelessWidget {
  const LexitoonsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexitoons Screening',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial', // You can add a custom Urdu font later
        primarySwatch: Colors.amber,
      ),
      home: const ParkSceneScreen(),
    );
  }
}