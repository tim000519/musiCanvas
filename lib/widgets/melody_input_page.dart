// lib/widgets/melody_input_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, Directory;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../models/note_event.dart';
import '../painters/sheet_music_painter.dart';
import '../services/api_service.dart';
import 'piano_key.dart';
import '../utils/file_saver.dart'; // 조건부 import: 웹일 경우 file_saver_web.dart, 모바일은 stub
import 'package:audioplayers/audioplayers.dart';

class MelodyInputPage extends StatefulWidget {
  const MelodyInputPage({super.key});

  @override
  _MelodyInputPageState createState() => _MelodyInputPageState();
}

class _MelodyInputPageState extends State<MelodyInputPage> {
  bool isRecording = false;
  Timer? metronomeTimer;
  int currentBeat = 0;
  DateTime? recordingStartTime;
  List<NoteEvent> recordedNotes = [];
  Map<String, DateTime> activeNotes = {};

  final int totalBeats = 32;
  final double bpm = 120.0;
  double get quarterNoteDuration => 60.0 / bpm;
  double get sixteenthNoteDuration => quarterNoteDuration / 4;

  final AudioPlayer _metronomePlayer = AudioPlayer();

  // 카운트다운 변수 추가 (초)
  int countdown = -1;

  String selectedGenre = "JAZZ";

  Map<String, bool> selectedInstruments = {
    "Guitar": false,
    "Piano": false,
    "Drums": false,
  };

    // 3초 카운트다운 후 녹음 시작
  void startCountdownAndRecording() {
    setState(() {
      countdown = 3;
    });
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          countdown = -1;
        });
        startRecording(); // 카운트다운이 끝나면 녹음 시작
      }
    });
  }

  void startRecording() {
    setState(() {
      isRecording = true;
      currentBeat = 0;
      recordedNotes.clear();
      activeNotes.clear();
      recordingStartTime = DateTime.now();
    });

    metronomeTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _metronomePlayer.play(AssetSource('sounds/met.mp3')).catchError((error) {
        print("Metronome error: $error");
      });
      setState(() {
        currentBeat++;
      });
      if (currentBeat >= totalBeats) {
        stopRecording();
      }
    });
  }

  void stopRecording() {
    metronomeTimer?.cancel();
    setState(() {
      isRecording = false;
    });
  }

  double quantizeTime(double inputTime) {
    return (inputTime / sixteenthNoteDuration).round() * sixteenthNoteDuration;
  }

  void onKeyPress(String note) {
    if (!isRecording) return;
    activeNotes[note] = DateTime.now();
  }

  void onKeyRelease(String note) {
    if (!isRecording) return;
    DateTime now = DateTime.now();
    if (activeNotes.containsKey(note)) {
      DateTime start = activeNotes[note]!;
      double startTimeSec = start.difference(recordingStartTime!).inMilliseconds / 1000.0;
      double endTimeSec = now.difference(recordingStartTime!).inMilliseconds / 1000.0;
      double durationSec = endTimeSec - startTimeSec;
      double quantizedStart = quantizeTime(startTimeSec);
      double quantizedDuration = quantizeTime(durationSec);
      NoteEvent event = NoteEvent(
        note: note,
        startTime: quantizedStart,
        duration: quantizedDuration,
      );
      setState(() {
        recordedNotes.add(event);
      });
      activeNotes.remove(note);
    }
  }


  Future<void> downloadMidiFile(
      BuildContext context, List<NoteEvent> recordedNotes, List<dynamic> genre) async {
    // 인자 전달 확인용 로그
    print("장르 설정: $genre");

    // 로컬 테스트의 경우
    const serverUrl = "http://localhost:8000";
    // API 호출 시 genre 인자도 함께 전달하도록 수정할 수 있음
    final response = await processMelody(recordedNotes, serverUrl, genre);
    
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      if (kIsWeb) {
        await saveFile(bytes, "output.mid");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("MIDI 파일이 다운로드 됩니다.")),
        );
      } else {
        Directory dir = await getApplicationDocumentsDirectory();
        String filePath = "${dir.path}/output.mid";
        File midiFile = File(filePath);
        await midiFile.writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("MIDI 파일이 저장되었습니다: $filePath")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("서버 처리 실패: ${response.statusCode}")),
      );
    }
  }


  @override
  void dispose() {
    metronomeTimer?.cancel();
    _metronomePlayer.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  List<String> whiteKeys = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
  List<String?> blackKeys = ['C_sharp', 'D_sharp', null, 'F_sharp', 'G_sharp', 'A_sharp', null];

  return Scaffold(
    appBar: AppBar(
      title: const Text('Melody Input'),
    ),
    body: Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("장르 선택", style: TextStyle(fontSize: 18)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedGenre == "JAZZ"
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedGenre = "JAZZ";
                        });
                      },
                      child: const Text("JAZZ"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selectedGenre == "ROCK" ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedGenre = "ROCK";
                        });
                      },
                      child: const Text("ROCK"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text("악기 선택", style: TextStyle(fontSize: 18)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: selectedInstruments.keys.map((instrument) {
                    return Row(
                      children: [
                        Checkbox(
                          value: selectedInstruments[instrument],
                          onChanged: (bool? value) {
                            setState(() {
                              selectedInstruments[instrument] = value ?? false;
                            });
                          },
                        ),
                        Text(instrument),
                        const SizedBox(width: 8),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            // 카운트다운 중이면 countdown 표시, 아니면 녹음 중 또는 대기 메시지 표시
            countdown > -1
                ? '시작까지 $countdown초'
                : isRecording
                    ? 'Recording... Beat ${currentBeat + 1}/$totalBeats'
                    : '녹음을 시작하려면 멜로디 작곡 버튼을 누르세요',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        Expanded(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double whiteKeyWidth = 50; //constraints.maxWidth / whiteKeys.length; // 흰 건반 너비 자동 조정
                double blackKeyWidth = whiteKeyWidth * 0.8; // 검은 건반은 흰 건반의 60% 크기

                return Stack(
                  children: [
                    // 흰 건반 (아래 배치)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: whiteKeys.map((note) {
                        return SizedBox(
                          width: whiteKeyWidth,
                          child: PianoKey(
                            note: note,
                            onPress: () => onKeyPress(note),
                            onRelease: () => onKeyRelease(note),
                            isBlack: false,
                          ),
                        );
                      }).toList(),
                    ),
                    // 검은 건반 (흰 건반 위에 겹쳐서 상대 위치로 배치)
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.only(left: blackKeyWidth * 1.3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: blackKeys.map((note) {
                            return note != null
                                ? SizedBox(
                                    width: whiteKeyWidth,
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: SizedBox(
                                        width: blackKeyWidth,
                                        height: 100, // 검은 건반 길이
                                        child: PianoKey(
                                          note: note,
                                          onPress: () => onKeyPress(note),
                                          onRelease: () => onKeyRelease(note),
                                          isBlack: true,
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(width: whiteKeyWidth); // 검은 건반이 없는 곳은 빈 공간
                          }).toList(),
                        )
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: isRecording ? null : startCountdownAndRecording,
                child: const Text('멜로디 작곡'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: isRecording ? stopRecording : null,
                child: const Text('멈춤'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                  onPressed: () {
                    // 장르 인자 리스트 생성: [장르, {악기: 유무}, ...]
                    List<dynamic> genreParam = [
                      selectedGenre,
                      ...selectedInstruments.entries.map((e) => {e.key: e.value})
                    ];
                    downloadMidiFile(context, recordedNotes, genreParam);
                  },
                  child: const Text('악보 처리 및 다운로드'),
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: recordedNotes
                  .map((e) => Text(
                      'Note ${e.note}: start ${e.startTime.toStringAsFixed(2)} s, duration ${e.duration.toStringAsFixed(2)} s'))
                  .toList(),
            ),
          ),
        ),
        Container(
          height: 200,
          color: Colors.grey[200],
          child: CustomPaint(
            painter: SheetMusicPainter(notes: recordedNotes),
            child: Container(),
          ),
        ),
      ],
    ),
  );
}
}
