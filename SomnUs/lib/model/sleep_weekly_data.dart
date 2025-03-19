import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:somnus/services/auth_service.dart';

/// 수면 데이터 모델 정의 (모든 필드를 평탄한 객체 형태로 처리)
class WeeklySleepData {
  // 주간 집계 데이터
  final String avg_deep_sleep;
  final String avg_light_sleep;
  final String avg_rem_sleep;
  final String avg_sleep_time;
  final int avg_sleep_score;
  final String week_number;
  final String aggregation_type;

  // 일별 데이터 (월요일 ~ 일요일)
  final int mon_score;
  final String mon_time;
  final int tue_score;
  final String tue_time;
  final int wed_score;
  final String wed_time;
  final int thu_score;
  final String thu_time;
  final int fri_score;
  final String fri_time;
  final int sat_score;
  final String sat_time;
  final int sun_score;
  final String sun_time;
  final List<String> chatbotResponse;


  WeeklySleepData({
    required this.avg_deep_sleep,
    required this.avg_light_sleep,
    required this.avg_rem_sleep,
    required this.avg_sleep_time,
    required this.avg_sleep_score,
    required this.week_number,
    required this.aggregation_type,
    required this.mon_score,
    required this.mon_time,
    required this.tue_score,
    required this.tue_time,
    required this.wed_score,
    required this.wed_time,
    required this.thu_score,
    required this.thu_time,
    required this.fri_score,
    required this.fri_time,
    required this.sat_score,
    required this.sat_time,
    required this.sun_score,
    required this.sun_time,
    required this.chatbotResponse
  });

  factory WeeklySleepData.fromJson(Map<String, dynamic> json) {
    // 🔹 `chatbot_response`가 List인지 확인하고 변환
    List<String> chatbotResponse = [];
    if (json["chatbot_response"] is List) {
      chatbotResponse = List<String>.from(json["chatbot_response"]);
    } else if (json["chatbot_response"] is String) {
      try {
        chatbotResponse = List<String>.from(jsonDecode(json["chatbot_response"]));
      } catch (e) {
        chatbotResponse = ["챗봇 응답을 분석할 수 없습니다"];
      }
    }
    return WeeklySleepData(
      avg_deep_sleep: json['avg_deep_sleep'],
      avg_light_sleep: json['avg_light_sleep'],
      avg_rem_sleep: json['avg_rem_sleep'],
      avg_sleep_time: json['avg_sleep_time'],
      avg_sleep_score: json['avg_sleep_score'],
      week_number: json['week_number'],
      aggregation_type: json['aggregation_type'],
      mon_score: json['mon_score'],
      mon_time: json['mon_time'],
      tue_score: json['tue_score'],
      tue_time: json['tue_time'],
      wed_score: json['wed_score'],
      wed_time: json['wed_time'],
      thu_score: json['thu_score'],
      thu_time: json['thu_time'],
      fri_score: json['fri_score'],
      fri_time: json['fri_time'],
      sat_score: json['sat_score'],
      sat_time: json['sat_time'],
      sun_score: json['sun_score'],
      sun_time: json['sun_time'],
      chatbotResponse: chatbotResponse
    );
  }
}

/// 챗봇 응답을 포함한 모델
class WeeklySleepDataResponse {
  final WeeklySleepData sleepData;
  final List<String> chatbotResponse;

  WeeklySleepDataResponse({
    required this.sleepData,
    required this.chatbotResponse,
  });

  factory WeeklySleepDataResponse.fromJson(Map<String, dynamic> json) {
    // chatbot_response가 Map이면 jsonEncode를 통해 문자열로 변환
    final dynamic chatbotResp = json['chatbot_response'];
    List<String> chatbotResponse = [];
    if (chatbotResp is List) {
      chatbotResponse = List<String>.from(chatbotResp);
    } else if (chatbotResp is String) {
      try {
        chatbotResponse = List<String>.from(jsonDecode(chatbotResp));
      } catch (e) {
        chatbotResponse = ["챗봇 응답을 분석할 수 없습니다"];
      }
    }
    return WeeklySleepDataResponse(
      sleepData: WeeklySleepData.fromJson(json),
      chatbotResponse: chatbotResponse,
    );
  }
}

/// API 호출 함수: FastAPI의 /sleep-data/weekly 엔드포인트를 호출하여 평탄화된 JSON 데이터를 반환
Future<WeeklySleepDataResponse> fetchWeeklySleepData(
  String selectedWeek,
) async {
  String? token = AuthService().getToken();
  if (token == null) {
    throw Exception("로그인이 필요합니다.");
  }
  final response = await http.get(
    Uri.parse(
      'http://192.168.219.211:8001/sleep-data/weekly?date=$selectedWeek',
    ),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final decodeBody = utf8.decode(response.bodyBytes);
    final Map<String, dynamic> jsonResponse = json.decode(decodeBody);
    // weekly_data와 daily_data를 평탄화: 두 Map을 합칩니다.
    final Map<String, dynamic> weeklyData =
        jsonResponse["weekly_data"] as Map<String, dynamic>;
    final Map<String, dynamic> dailyData =
        jsonResponse["daily_data"] as Map<String, dynamic>;
    final combinedJson = {...weeklyData, ...dailyData};
    // 챗봇 응답은 따로 저장 (combinedJson에 포함시키지 않고 SleepDataResponse.fromJson 에서 처리할 수도 있음)
    combinedJson["chatbot_response"] = jsonResponse["chatbot_response"];
    return WeeklySleepDataResponse.fromJson(combinedJson);
  } else {
    throw Exception("수면 데이터를 불러오는데 실패했습니다. 응답: ${response.body}");
  }
}

class WeeklySleepDataScreen extends StatefulWidget {
  const WeeklySleepDataScreen({Key? key}) : super(key: key);

  @override
  _SleepDataScreenState createState() => _SleepDataScreenState();
}

class _SleepDataScreenState extends State<WeeklySleepDataScreen> {
  late Future<WeeklySleepDataResponse> futureWeeklySleepData;

  @override
  void initState() {
    super.initState();
    futureWeeklySleepData = fetchWeeklySleepData("3월 2주차");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("수면 데이터")),
      body: Center(
        child: FutureBuilder<WeeklySleepDataResponse>(
          future: futureWeeklySleepData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('에러: ${snapshot.error}');
            } else {
              WeeklySleepDataResponse responseData = snapshot.data!;
              WeeklySleepData data = responseData.sleepData;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '평균 수면 시간: ${data.avg_sleep_time}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '평균 수면 점수: ${data.avg_sleep_score}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '평균 딥슬립: ${data.avg_deep_sleep}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '평균 얕은슬립: ${data.avg_light_sleep}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '평균 렘슬립: ${data.avg_rem_sleep}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '주차: ${data.week_number}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Divider(),
                    Text(
                      '월요일 점수: ${data.mon_score}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '월요일 시간: ${data.mon_time}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Divider(),
                    Text(
                      '화요일 점수: ${data.tue_score}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '화요일 시간: ${data.tue_time}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Divider(),
                    Text(
                      '수요일 점수: ${data.wed_score}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '수요일 시간: ${data.wed_time}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Divider(),
                    Text(
                      '목요일 점수: ${data.thu_score}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '목요일 시간: ${data.thu_time}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Divider(),
                    Text(
                      '금요일 점수: ${data.fri_score}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '금요일 시간: ${data.fri_time}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Divider(),
                    Text(
                      '토요일 점수: ${data.sat_score}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '토요일 시간: ${data.sat_time}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Divider(),
                    Text(
                      '일요일 점수: ${data.sun_score}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '일요일 시간: ${data.sun_time}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "챗봇 응답:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
