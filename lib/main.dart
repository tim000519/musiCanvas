// lib/main.dart
import 'package:flutter/material.dart';
import 'widgets/melody_input_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyMelodyApp());
}

class MyMelodyApp extends StatelessWidget {
  const MyMelodyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Canvas',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 255, 233, 125),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(159, 79, 70, 1),
            // backgroundColor: const Color.fromRGBO(170, 177, 183, 1),
            // backgroundColor: const Color.fromRGBO(155, 62, 51, 1),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        chipTheme: ChipThemeData(
          selectedColor: const Color.fromARGB(255, 255, 255, 255),
          labelStyle: const TextStyle(color: Colors.white),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 2,
        ),
        fontFamily: 'Pretendard', // 원하는 글꼴 지정
        useMaterial3: true, // Material 3 스타일
      ),
      home: const MelodyInputPage(),
    );
  }
}
