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
      title: 'Melody Input App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MelodyInputPage(),
    );
  }
}
