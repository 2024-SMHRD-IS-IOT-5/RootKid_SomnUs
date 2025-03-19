import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class SleepMusicScreen extends StatefulWidget {

  const SleepMusicScreen({super.key});

  @override
  _SleepMusicScreenState createState() => _SleepMusicScreenState();
}

class _SleepMusicScreenState extends State<SleepMusicScreen> {
  // 음악 목록: title, image, isPlaying 상태, (선택) 서버 전송용 메시지
  List<Map<String, dynamic>> sleepMusicList = [
    {
      "title": "백색 소음",
      "image": "images/night.jpg",
      "isPlaying": false,
      "serverMsg": "white_noise",
    },
    {
      "title": "빗소리",
      "image": "images/rain.jpg",
      "isPlaying": false,
      "serverMsg": "rain",
    },
    {
      "title": "피아노 소리",
      "image": "images/piano.jpg",
      "isPlaying": false,
      "serverMsg": "piano",
    },
    {
      "title": "고래 소리",
      "image": "images/dolphin.png",
      "isPlaying": false,
      "serverMsg": "whale",
    },
    {
      "title": "자연 소리",
      "image": "images/nature.jpg",
      "isPlaying": false,
      "serverMsg": "nature",
    },
  ];

  // 서버에 음악 재생/정지 상태를 전송하는 예시 함수
  Future<void> _sendMusicStateToServer(String serverMsg, bool isPlaying) async {
    final action = isPlaying? "play" : "pause";
    // 실제 서버 URL 및 파라미터는 백엔드에 맞춰 수정 필요
    final url = Uri.parse('http://192.168.219.211:8001/stream?title=$serverMsg&action=$action');

    // 예: {"music": "piano_sound", "action": "play"} or "pause"
    final bodyData = {
      "music": serverMsg,
      "action": isPlaying ? "play" : "pause",
    };

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        print("서버에 전송 성공: ${response.body}");
      } else {
        print("서버 에러: ${response.statusCode} / ${response.body}");
      }
    } catch (e) {
      print("서버 요청 중 에러: $e");
    }
  }

  // 음악 재생/일시정지 토글
  void _togglePlay(int index) {
    setState(() {
      // 선택된 음악의 isPlaying 상태를 토글
      sleepMusicList[index]["isPlaying"] = !sleepMusicList[index]["isPlaying"];
    });
    // 서버에 상태 전송
    _sendMusicStateToServer(
      sleepMusicList[index]["serverMsg"],
      sleepMusicList[index]["isPlaying"],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "수면 음악 플레이리스트",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 상단 구분선 (선택 사항)
          Container(
            height: 1.5,
            color: Colors.black12,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sleepMusicList.length,
              itemBuilder: (context, index) {
                final music = sleepMusicList[index];
                return Column(
                  children: [
                    InkWell(
                      onTap: () => _togglePlay(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        color: Colors.white,
                        child: Row(
                          children: [
                            // 이미지
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                music["image"],
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // 제목
                            Expanded(
                              child: Text(
                                music["title"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // 재생/일시정지 아이콘
                            Icon(
                              music["isPlaying"]
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              size: 30,
                              color: const Color(0xFF141932),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 각 아이템 사이의 구분선
                    Container(
                      height: 1,
                      color: Colors.black12,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}