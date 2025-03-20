import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:somnus/services/auth_service.dart';
import 'package:somnus/config/config.dart';

/// 월간 데이터와 주간 데이터를 담는 모델 클래스
class SleepDataMonthly {
  // 월간 데이터 필드
  final String avg_deep_sleep;
  final String avg_light_sleep;
  final String avg_rem_sleep;
  final String avg_sleep_time;
  final int avg_sleep_score;
  final String month_number;

  final int w1_score;
  final String w1_time;
  final int w2_score;
  final String w2_time;
  final int w3_score;
  final String w3_time;
  final int w4_score;
  final String w4_time;
  final int w5_score;
  final String w5_time;
  final String chatbotResponse;
  final int min_sleep_score;
  final int max_sleep_score;
  final String min_sleep_time;
  final String max_sleep_time;

  SleepDataMonthly({
    required this.avg_deep_sleep,
    required this.avg_light_sleep,
    required this.avg_rem_sleep,
    required this.avg_sleep_time,
    required this.avg_sleep_score,
    required this.month_number,
    required this.w1_score,
    required this.w1_time,
    required this.w2_score,
    required this.w2_time,
    required this.w3_score,
    required this.w3_time,
    required this.w4_score,
    required this.w4_time,
    required this.w5_score,
    required this.w5_time,
    required this.chatbotResponse,
    required this.min_sleep_score,
    required this.max_sleep_score,
    required this.max_sleep_time,
    required this.min_sleep_time
  });

  factory SleepDataMonthly.fromJson(Map<String, dynamic> json) {
    return SleepDataMonthly(
      avg_deep_sleep: json["avg_deep_sleep"],
      avg_light_sleep: json["avg_light_sleep"],
      avg_rem_sleep: json["avg_rem_sleep"],
      avg_sleep_time: json["avg_sleep_time"],
      avg_sleep_score: json["avg_sleep_score"],
      month_number: json["month_number"]?.toString() ?? "",
      w1_score: json["1w_score"],
      w1_time: json["1w_time"],
      w2_score: json["2w_score"],
      w2_time: json["2w_time"],
      w3_score: json["3w_score"],
      w3_time: json["3w_time"],
      w4_score: json["4w_score"],
      w4_time: json["4w_time"],
      w5_score: json["5w_score"],
      w5_time: json["5w_time"],
      chatbotResponse: json["chatbot_response"] ?? "특이사항없음",
      min_sleep_score: json["min_sleep_score"],
      max_sleep_score: json["max_sleep_score"],
      min_sleep_time: json["min_sleep_time"],
      max_sleep_time: json["max_sleep_time"]
      //w5_score: int.tryParse(json['w5_score']?.toString() ?? "") ?? 0,
      //w5_time: json['w5_time']?.toString() ?? "데이터 없음",
    );
  }
}

/// 챗봇 응답을 포함한 모델
class MonthlySleepDataResponse {
  final SleepDataMonthly sleepData;
  final String chatbotResponse;

  MonthlySleepDataResponse({
    required this.sleepData,
    required this.chatbotResponse,
  });

  factory MonthlySleepDataResponse.fromJson(Map<String, dynamic> json) {
    // chatbot_response가 Map이면 jsonEncode를 통해 문자열로 변환
    final dynamic chatbotResp = json['chatbot_response'];
    String chatbotResponse =
        chatbotResp is String ? chatbotResp : jsonEncode(chatbotResp);
    return MonthlySleepDataResponse(
      sleepData: SleepDataMonthly.fromJson(json),
      chatbotResponse: chatbotResponse,
    );
  }
}

/// FastAPI의 /sleep-data/monthly 엔드포인트를 호출하여 평탄한 JSON 데이터를 반환
Future<MonthlySleepDataResponse> fetchMonthlySleepData() async {
  String? token = AuthService().getToken();
  if (token == null) {
    throw Exception("로그인이 필요합니다.");
  }
  final response = await http.get(
    Uri.parse('${Config.baseUrl}/sleep-data/monthly'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final decodeBody = utf8.decode(response.bodyBytes);
    final Map<String, dynamic> jsonResponse = json.decode(decodeBody);
    // monthlyData weeklyData 평탄화: 두 Map을 합칩니다.
    final Map<String, dynamic> monthlyData =
        jsonResponse["monthly_data"] as Map<String, dynamic>;
    final Map<String, dynamic> weeklyData =
        jsonResponse["weekly_data"] as Map<String, dynamic>;
    final combinedJson = {...monthlyData, ...weeklyData};
    // 챗봇 응답은 따로 저장 (combinedJson에 포함시키지 않고 SleepDataResponse.fromJson 에서 처리할 수도 있음)
    combinedJson["chatbot_response"] = jsonResponse["chatbot_response"];
    combinedJson["min_sleep_score"] = jsonResponse["min_sleep_score"];
    combinedJson["max_sleep_score"] = jsonResponse["max_sleep_score"];
    combinedJson["min_sleep_time"] = jsonResponse["min_sleep_time"];
    combinedJson["max_sleep_time"] = jsonResponse["max_sleep_time"];
    return MonthlySleepDataResponse.fromJson(combinedJson);
  } else {
    throw Exception("수면 데이터를 불러오는데 실패했습니다. 응답: ${response.body}");
  }
}

class SleepDataScreenMonthly extends StatefulWidget {
  const SleepDataScreenMonthly({Key? key}) : super(key: key);

  @override
  _MonthlyDataScreenState createState() => _MonthlyDataScreenState();
}

class _MonthlyDataScreenState extends State<SleepDataScreenMonthly> {
  late Future<MonthlySleepDataResponse> futureMonthlySleepData;

  @override
  void initState() {
    super.initState();
    futureMonthlySleepData = fetchMonthlySleepData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("수면 데이터")),
      body: Center(
        child: FutureBuilder<MonthlySleepDataResponse>(
          future: futureMonthlySleepData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('에러: ${snapshot.error}');
            } else {
              MonthlySleepDataResponse responseData = snapshot.data!;
              SleepDataMonthly data = responseData.sleepData;
              String chatbotResponse = responseData.chatbotResponse;
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
                      '월: ${data.month_number}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Divider(),
                    Text(
                      '1주차 점수: ${data.w1_score}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '1주차 시간: ${data.w1_time}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Divider(),
                    Text(
                      '2주차 점수: ${data.w2_score}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '2주차 시간: ${data.w2_time}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Divider(),
                    Text(
                      '3주차 점수: ${data.w3_score}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '3주차 시간: ${data.w3_time}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Divider(),
                    Text(
                      '4주차 점수: ${data.w4_score}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '4주차 시간: ${data.w4_time}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Divider(),
                    //Text('5주차 점수: ${data.w5_score}', style: const TextStyle(fontSize: 18)),
                    //Text('5주차 시간: ${data.w5_time}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    Text(
                      "이번달 최저 점수 : ${data.min_sleep_score}",
                      style : const TextStyle(fontSize: 18),
                    ),
                    const Text(
                      "챗봇 응답:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(chatbotResponse, style: const TextStyle(fontSize: 16)),
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
