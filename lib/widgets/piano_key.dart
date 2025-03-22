import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PianoKey extends StatefulWidget {
  final String note;
  final VoidCallback onPress;
  final VoidCallback onRelease;
  final bool isBlack; // 검은 건반 여부

  const PianoKey({
    Key? key,
    required this.note,
    required this.onPress,
    required this.onRelease,
    this.isBlack = false,
  }) : super(key: key);

  @override
  _PianoKeyState createState() => _PianoKeyState();
}

class _PianoKeyState extends State<PianoKey> {
  bool isPressed = false;

  final AudioPlayer _player = AudioPlayer();

  void playSound() async {
    String fileName = widget.note;
    try {
      // 현재 재생 중인 소리가 있다면 중지한 후 재생합니다.
      await _player.stop();
      await _player.play(AssetSource('sounds/$fileName.mp3'));
    } catch (error) {
      print("Error playing sound: $error");
    }
  }

  @override
  void dispose() {
    _player.dispose(); // AudioPlayer 리소스 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isPressed = true;
        });
        widget.onPress();
        playSound();
      },
      onTapUp: (_) {
        setState(() {
          isPressed = false;
        });
        widget.onRelease();
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
        widget.onRelease();
      },
      child: Container(
        width: widget.isBlack ? 30 : 50, // 검은 건반은 더 좁게
        height: widget.isBlack ? 100 : 150, // 검은 건반은 더 짧게
        margin: widget.isBlack ? const EdgeInsets.symmetric(horizontal: 5) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isPressed
              ? (widget.isBlack ? Colors.black87 : Colors.blueAccent)
              : (widget.isBlack ? Colors.black : Colors.white),
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
