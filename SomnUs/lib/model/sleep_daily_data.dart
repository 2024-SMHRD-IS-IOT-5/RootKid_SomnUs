import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:somnus/services/auth_service.dart';

// ✅ 수면 데이터 모델 정의
class DailySleepData {
  final String date;
  final String startDt;
  final String endDt;
  final String sleepTime;
  final String deepSleep;
  final String lightSleep;
  final String remSleep;
  final int sleepScore;
  final String wakeupcount;    // 깨는 수
  final String hr_average;     // 평균 심박수
  final String hr_min;         // 최소 심박수
  final String hr_max;         // 최대 심박수
  final String rr_average;     // 평균 호흡수
  final String rr_min;         // 최소 호흡수
  final String rr_max;         // 최대 호흡수
  final String breathing_disturbances_intensity;  // 호흡 곤란
  final String snoring;       // 코골이 시간
  final String snoringepisodecount;  // 코골이 횟수


  DailySleepData({
    required this.date,
    required this.startDt,
    required this.endDt,
    required this.sleepTime,
    required this.deepSleep,
    required this.lightSleep,
    required this.remSleep,
    required this.sleepScore,
    required this.wakeupcount,
    required this.hr_average,
    required this.hr_min,
    required this.hr_max,
    required this.rr_average,
    required this.rr_min,
    required this.rr_max,
    required this.breathing_disturbances_intensity,
    required this.snoring,
    required this.snoringepisodecount,

  });

  factory DailySleepData.fromJson(Map<String, dynamic> json) {
    return DailySleepData(
      date: json['date'].toString(),
      startDt: json['startDt'].toString(),
      endDt: json['endDt'].toString(),
      sleepTime: json['sleep_time'].toString(),
      deepSleep: json['deepsleep'].toString(),
      lightSleep: json['lightsleep'].toString(),
      remSleep: json['remsleep'].toString(),
      sleepScore: json['sleep_score'] is int ? json['sleep_score'] : int.parse(json['sleep_score'].toString()),
      wakeupcount: json['wakeupcount'].toString(),
      hr_average: json['hr_average'].toString(),
      hr_min: json['hr_min'].toString(),
      hr_max: json['hr_max'].toString(),
      rr_average: json['rr_average'].toString(),
      rr_min: json['rr_min'].toString(),
      rr_max: json['rr_max'].toString(),
      breathing_disturbances_intensity: json['breathing_disturbances_intensity'].toString(),
      snoring: json['snoring'].toString(),
      snoringepisodecount: json['snoringepisodecount'].toString(),
    );
  }
}

// ✅ 챗봇 응답을 포함한 모델
class DailySleepDataResponse {
  final DailySleepData sleepData;
  final String chatbotResponse;

  DailySleepDataResponse({required this.sleepData, required this.chatbotResponse});

  //factory SleepDataResponse.fromJson(Map<String, dynamic> json) {
  // return SleepDataResponse(
  // sleepData: SleepData.fromJson(json['sleep_data']),
  // chatbotResponse: json['chatbot_response'],
  // );
  // }
  //}
  factory DailySleepDataResponse.fromJson(Map<String, dynamic> json) {
    final dynamic chatbotResp = json['chatbot_response'];
    String chatbotResponse =
        chatbotResp is String ? chatbotResp : jsonEncode(chatbotResp);
    return DailySleepDataResponse(
      sleepData: DailySleepData.fromJson(json['sleep_data']),
      chatbotResponse: chatbotResponse,
    );
  }
}

// ✅ API 호출 함수 (AuthService에서 토큰 가져오기)
Future<DailySleepDataResponse> fetchDailySleepData(String date) async {
  String? token = AuthService().getToken(); // ✅ 로그인된 토큰 가져오기

  if (token == null) {
    throw Exception("로그인이 필요합니다.");
  }

  final response = await http.get(
    Uri.parse('http://192.168.219.211:8001/sleep-data/calendar?date=$date'),
    headers: {'Authorization': 'Bearer $token'},

  );



  if (response.statusCode == 200) {
    // 한글 깨짐 방지(UTF-8 디코딩 적용)
    final decodeBody = utf8.decode(response.bodyBytes);
    final Map<String, dynamic> jsonResponse = json.decode(decodeBody);

    // ✅ 챗봇 응답을 result에서 가져오기
    String chatbotResponse = jsonResponse['chatbot_response'] ?? "챗봇 응답 없음";

    return DailySleepDataResponse(
      sleepData: DailySleepData.fromJson(jsonResponse['sleep_data']),
      chatbotResponse: chatbotResponse,
    );
  } else {
    throw Exception("수면 데이터를 불러오는데 실패했습니다. 응답: ${response.body}");
  }
}



class SleepDataScreen extends StatefulWidget {
  final String date; // 날짜를 받을 변수 추가
  const SleepDataScreen({Key? key, required this.date}) : super(key:key);

  @override
  _SleepDataScreenState createState() => _SleepDataScreenState();
}

class _SleepDataScreenState extends State<SleepDataScreen> {
  late Future<DailySleepDataResponse> futureDailySleepData;

  @override
  void initState() {
    super.initState();
    futureDailySleepData = fetchDailySleepData(widget.date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("수면 데이터")),
      body: Center(
        child: FutureBuilder<DailySleepDataResponse>(
          future: futureDailySleepData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('에러: ${snapshot.error}');
            } else {
              DailySleepDataResponse responseData =
                  snapshot.data!; // ✅ SleepDataResponse로 변경
              DailySleepData data = responseData.sleepData;
              String chatbotResponse = responseData.chatbotResponse;
              print("📡 챗봇 응답 데이터: $chatbotResponse");
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('날짜: ${data.date}'),
                  Text('수면 시간: ${data.sleepTime}'),
                  Text('수면 점수: ${data.sleepScore}'),
                  Text('시간: ${data.startDt} ~ ${data.endDt}'),
                  SizedBox(height: 20),
                  Text(
                    "💬 챗봇 피드백",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(chatbotResponse, style: TextStyle(fontSize: 16)),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
