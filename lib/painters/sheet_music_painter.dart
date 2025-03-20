// lib/painters/sheet_music_painter.dart
import 'package:flutter/material.dart';
import '../models/note_event.dart';

class SheetMusicPainter extends CustomPainter {
  final List<NoteEvent> notes;
  final double pixelsPerSecond;
  final double staffTop;
  final double staffSpacing;

  SheetMusicPainter({
    required this.notes,
    this.pixelsPerSecond = 40, // 1초당 50픽셀
    this.staffTop = 50,        // 오선 시작 y좌표
    this.staffSpacing = 10,    // 오선 간격
  });

  // 음표 이름을 y좌표로 매핑 (간단 예제)
  double noteToY(String note) {
    const notesOrder = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
    int index = notesOrder.indexOf(note);
    if (index == -1) index = 0;
    return staffTop + 1.5 * staffSpacing - index * staffSpacing * 0.5;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    // 오선 5줄 그리기
    for (int i = 0; i < 5; i++) {
      double y = staffTop + i * staffSpacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 각 NoteEvent에 대해 음표(타원) 그리기
    for (var note in notes) {
      double x = note.startTime * pixelsPerSecond;
      double y = noteToY(note.note);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 10, height: 7),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
