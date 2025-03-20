// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note_event.dart';

/// FastAPI 서버에 멜로디 데이터를 보내고, MIDI 파일 바이너리를 반환받는 함수
/// [genre] 인자는 장르 및 악기 선택 정보를 담은 리스트입니다.
Future<http.Response> processMelody(
  List<NoteEvent> notes,
  String serverUrl,
  List<dynamic> genre, // 추가된 인자: 장르 및 악기 정보
) async {
  List<Map<String, dynamic>> notesJson = notes.map((note) {
    return {
      "note": note.note,
      "start": note.startTime,
      "duration": note.duration,
    };
  }).toList();

  final url = Uri.parse("$serverUrl/process");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    // body에 "notes"와 "genre" 정보를 모두 포함하여 전송합니다.
    body: jsonEncode({
      "notes": notesJson,
      "genre": genre, // 장르 및 악기 설정 정보 추가
    }),
  );
  return response;
}
