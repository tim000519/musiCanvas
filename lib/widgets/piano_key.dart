import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PianoKey extends StatefulWidget {
  final String note;
  final VoidCallback onPress;
  final VoidCallback onRelease;
  final bool isBlack; // 검은 건반인지 여부

  const PianoKey({
    super.key,
    required this.note,
    required this.onPress,
    required this.onRelease,
    this.isBlack = false, // 기본적으로 흰 건반
  });

  @override
  _PianoKeyState createState() => _PianoKeyState();
}

class _PianoKeyState extends State<PianoKey> {
  bool isPressed = false;

  final AudioPlayer _player = AudioPlayer();

  void playSound() {
    String fileName = widget.note.replaceAll("#", "_sharp");
    _player.play(AssetSource('sounds/$fileName.mp3')).then((value) {
      // 재생 성공
    }).catchError((error) {
      print("Error playing sound: $error");
    });
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
        // child: Center(
        //   child: Text(
        //     widget.note,
        //     style: TextStyle(
        //       fontSize: 18,
        //       color: widget.isBlack ? Colors.white : Colors.black, // 검은 건반 글자는 흰색
        //     ),
        //   ),
        // ),
      ),
    );
  }
}


