import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:somnus/services/auth_service.dart';

// ✅ 수면 데이터 모델 정의
class SleepData {
  final String avg_deep_sleep;
  final String avg_light_sleep;
  final String avg_rem_sleep;
  final String avg_sleep_time;
  final int avg_sleep_score;
  final String week_number;

  SleepData({
    required this.avg_deep_sleep,
    required this.avg_light_sleep,
    required this.avg_rem_sleep,
    required this.avg_sleep_time,
    required this.avg_sleep_score,
    required this.week_number,
  });

  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      avg_deep_sleep: json['avg_deep_sleep'].toString(),
      avg_light_sleep: json['avg_light_sleep'].toString(),
      avg_rem_sleep: json['avg_rem_sleep'].toString(),
      avg_sleep_time: json['avg_sleep_time'].toString(),
      avg_sleep_score: json['avg_sleep_score'],
      week_number: json['week_number'].toString(),
    );
  }
}

// ✅ 챗봇 응답을 포함한 모델
class SleepDataResponse {
  final SleepData sleepData;
  final String chatbotResponse;

  SleepDataResponse({required this.sleepData, required this.chatbotResponse});

  factory SleepDataResponse.fromJson(Map<String, dynamic> json) {
    final dynamic chatbotResp = json['chatbot_response'];
    String chatbotResponse =
        chatbotResp is String ? chatbotResp : jsonEncode(chatbotResp);
    return SleepDataResponse(
      sleepData: SleepData.fromJson(json['sleep_data']),
      chatbotResponse: chatbotResponse,
    );
  }
}

// ✅ API 호출 함수 (AuthService에서 토큰 가져오기)
Future<SleepDataResponse> fetchSleepData() async {
  String? token = AuthService().getToken(); // ✅ 로그인된 토큰 가져오기

  if (token == null) {
    throw Exception("로그인이 필요합니다.");
  }

  final response = await http.get(
    Uri.parse('http://192.168.219.211:8001/sleep-data/weekly'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    // 한글 깨짐 방지(UTF-8 디코딩 적용)
    final decodeBody = utf8.decode(response.bodyBytes);
    final Map<String, dynamic> jsonResponse = json.decode(decodeBody);

    // ✅ 챗봇 응답을 result에서 가져오기
    String chatbotResponse = jsonResponse['chatbot_response'] ?? "챗봇 응답 없음";

    return SleepDataResponse(
      sleepData: SleepData.fromJson(jsonResponse['sleep_data']),
      chatbotResponse: chatbotResponse,
    );
  } else {
    throw Exception("수면 데이터를 불러오는데 실패했습니다. 응답: ${response.body}");
  }
}

class SleepDataScreenWeekly extends StatefulWidget {
  const SleepDataScreenWeekly({super.key});

  @override
  _SleepDataScreenState createState() => _SleepDataScreenState();
}

class _SleepDataScreenState extends State<SleepDataScreenWeekly> {
  late Future<SleepDataResponse> futureSleepData;

  @override
  void initState() {
    super.initState();
    futureSleepData = fetchSleepData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("수면 데이터")),
      body: Center(
        child: FutureBuilder<SleepDataResponse>(
          future: futureSleepData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('에러: ${snapshot.error}');
            } else {
              SleepDataResponse responseData =
                  snapshot.data!; // ✅ SleepDataResponse로 변경
              SleepData data = responseData.sleepData;
              String chatbotResponse = responseData.chatbotResponse;
              print("📡 챗봇 응답 데이터: $chatbotResponse");
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('딥슬립: ${data.avg_deep_sleep}'),
                  Text('얕은슬립: ${data.avg_light_sleep}'),
                  Text('렘슬립: ${data.avg_rem_sleep}'),
                  Text('시간: ${data.avg_sleep_time}'),
                  Text('점수: ${data.avg_sleep_score}'),
                  Text('주차: ${data.week_number}'),
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
