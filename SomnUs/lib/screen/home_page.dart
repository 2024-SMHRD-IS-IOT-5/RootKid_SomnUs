// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
//
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ✅ 오늘의 수면 요약
//               const SleepSummaryWidget(),
//               const SizedBox(height: 30),
//
//               // ✅ 수면 점수 피드백
//               _buildFeedbackCard(),
//               const SizedBox(height: 30),
//
//               // ✅ 수면 분석 및 통계 (바 차트)
//               const Text("수면 분석 및 통계", style: _titleStyle),
//               const SizedBox(height: 10),
//               _buildSleepBarChart(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // 📌 수면 분석 차트 (Placeholder)
//   Widget _buildSleepBarChart() {
//     return Container(
//       width: double.infinity,
//       height: 250,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 4,
//             offset: const Offset(2, 2),
//           ),
//         ],
//       ),
//       child: const Center(
//         child: Text(
//           "📊 수면 분석 차트 (Bar Chart) 들어갈 자리",
//           style: TextStyle(color: Colors.grey, fontSize: 14),
//         ),
//       ),
//     );
//   }
//
//   // 📌 피드백 카드
//   Widget _buildFeedbackCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 4,
//             offset: const Offset(2, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Text(
//                 "Somnus",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,)),
//               const SizedBox(width: 5),
//               const Icon(Icons.feedback_outlined, color: Colors.black, size: 22),
//             ],
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             "수면점수가 80점이네요! 최고의 컨디션! 지금처럼 꾸준히 유지하면 건강한 수면 습관을 가질 수 있어요! 💪",
//             style: TextStyle(fontSize: 14, color: Colors.black),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 📌 공통 스타일
//   static const TextStyle _titleStyle = TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.bold,
//     color: Colors.black,
//   );
// }
//
// // -----------------------------------------------------------
// // ✅ 도넛형 수면 요약 차트 위젯 (하단 20% 비우기)
// // -----------------------------------------------------------
// class SleepSummaryWidget extends StatelessWidget {
//   const SleepSummaryWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "오늘의 수면 요약",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildSleepDurationChart(),
//             _buildSleepScoreChart(),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // 📌 수면 시간 도넛형 차트
//   Widget _buildSleepDurationChart() {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         SizedBox(
//           width: 180,
//           height: 180,
//           child: SfCircularChart(
//             series: <CircularSeries>[
//               DoughnutSeries<_ChartData, String>(
//                 dataSource: [
//                   _ChartData("수면", 80, Colors.blue),
//                   _ChartData("남은 부분", 20, Colors.grey.shade300),
//                 ],
//                 xValueMapper: (_ChartData data, _) => data.category,
//                 yValueMapper: (_ChartData data, _) => data.value,
//                 pointColorMapper: (_ChartData data, _) => data.color,
//                 innerRadius: "70%",
//                 startAngle: 216,
//                 endAngle: 504,
//               ),
//             ],
//           ),
//         ),
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.nightlight_sharp, color: Colors.blue, size: 30),
//             const SizedBox(height: 1),
//             const Text(
//               "9시간 11분",
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//             const Text(
//               "00:13 ~ 09:24",
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // 📌 수면 점수 도넛형 차트
//   Widget _buildSleepScoreChart() {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         SizedBox(
//           width: 180,
//           height: 180,
//           child: SfCircularChart(
//             series: <CircularSeries>[
//               DoughnutSeries<_ChartData, String>(
//                 dataSource: [
//                   _ChartData("수면 점수", 80, Colors.green),
//                   _ChartData("남은 부분", 20, Colors.grey.shade300),
//                 ],
//                 xValueMapper: (_ChartData data, _) => data.category,
//                 yValueMapper: (_ChartData data, _) => data.value,
//                 pointColorMapper: (_ChartData data, _) => data.color,
//                 innerRadius: "70%",
//                 startAngle: 216,
//                 endAngle: 504,
//               ),
//             ],
//           ),
//         ),
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text("😀", style: TextStyle(fontSize: 24)),
//             const SizedBox(height: 1),
//             const Text(
//               "좋음",
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
//             ),
//             const SizedBox(height: 1),
//             const Text("수면점수", style: TextStyle(fontSize: 12, color: Colors.grey)),
//             const SizedBox(height: 1),
//             const Text(
//               "80점",
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// // ✅ 도넛형 차트를 위한 데이터 모델
// class _ChartData {
//   final String category;
//   final double value;
//   final Color color;
//
//   _ChartData(this.category, this.value, this.color);
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:somnus/screen/sleep_screen.dart';
import 'package:somnus/services/auth_service.dart';

// ✅ API에서 데이터 가져오기
Future<SleepDataResponse> fetchSleepData() async {
  String? token = AuthService().getToken();

  if (token == null) {
    throw Exception("로그인이 필요합니다.");
  }

  final response = await http.get(
    Uri.parse('http://192.168.219.211:8001/sleep-data'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final decodeBody = utf8.decode(response.bodyBytes);
    final Map<String, dynamic> jsonResponse = json.decode(decodeBody);
    return SleepDataResponse.fromJson(jsonResponse);
  } else {
    throw Exception("수면 데이터를 불러오는데 실패했습니다.");
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<SleepDataResponse> futureSleepData;

  @override
  void initState() {
    super.initState();
    futureSleepData = fetchSleepData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<SleepDataResponse>(
        future: futureSleepData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("에러: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("데이터가 없습니다."));
          }

          // ✅ API 데이터 할당
          SleepData data = snapshot.data!.sleepData;
          String chatbotComment = snapshot.data!.chatbotResponse;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ 오늘의 수면 요약
                  SleepSummaryWidget(
                    sleepTime: data.sleepTime,
                    sleepScore: data.sleepScore,
                    chatbotComment: chatbotComment,
                  ),
                  const SizedBox(height: 20),

                  // ✅ 수면 분석 및 통계
                  _buildSleepStats(data),
                  const SizedBox(height: 20),

                  // ✅ 수면 캘린더
                  _buildSleepCalendar(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 📌 수면 기록 테이블
  Widget _buildSleepStats(SleepData data) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSleepStatRow("REM 수면", data.remSleep),
          _buildSleepStatRow("얕은 수면", data.lightSleep),
          _buildSleepStatRow("깊은 수면", data.deepSleep),
        ],
      ),
    );
  }

  Widget _buildSleepStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 📌 수면 캘린더
  Widget _buildSleepCalendar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "2025.02",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return const Center(child: Text("📅 캘린더 표시 예정"));
  }
}

// -----------------------------------------------------------
// ✅ 도넛형 수면 요약 차트 위젯 (수면 점수 색상 변경 + SomnUs 코멘트 추가)
// -----------------------------------------------------------
class SleepSummaryWidget extends StatelessWidget {
  final String sleepTime;
  final int sleepScore;
  final String chatbotComment;

  const SleepSummaryWidget({
    super.key,
    required this.sleepTime,
    required this.sleepScore,
    required this.chatbotComment,
  });

  // ✅ 수면 점수에 따른 색상 설정
  Color getSleepScoreColor(int score) {
    if (score <= 25) return Colors.red;
    if (score <= 50) return Colors.orange;
    if (score <= 75) return Colors.green;
    return Colors.blue;
  }

  // ✅ 문자열 sleepTime을 double 값으로 변환하는 함수
  double parseSleepTime(String timeString) {
    // "9시간 11분" → "9.18" 같은 형식으로 변환
    RegExp regex = RegExp(r'(\d+)시간\s*(\d*)분*');
    Match? match = regex.firstMatch(timeString);

    if (match != null) {
      double hours = double.parse(match.group(1) ?? "0");
      double minutes = match.group(2)?.isNotEmpty == true
          ? double.parse(match.group(2)!) / 60.0
          : 0.0;
      return hours + minutes; // ✅ 변환된 double 값 반환
    }
    return 0.0; // 변환 실패 시 기본값
  }

  @override
  Widget build(BuildContext context) {
    Color scoreColor = getSleepScoreColor(sleepScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "오늘의 수면 요약",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSleepChart(
              "수면시간",
              sleepTime,
              Icons.nightlight_round,
              Colors.blue,
              true,
              parseSleepTime(sleepTime), // ✅ 변환된 값 전달
            ),
            _buildSleepChart(
              "수면점수",
              "$sleepScore점",
              Icons.sentiment_satisfied,
              scoreColor,
              false,
              sleepScore.toDouble(),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // 📌 SomnUs 챗봇 코멘트 표시
        _buildChatbotComment(chatbotComment),
      ],
    );
  }

  Widget _buildSleepChart(
      String label,
      String value,
      IconData icon,
      Color color,
      bool isSleepTime, // ✅ 수면시간인지 여부 추가
      double sleepValue, // ✅ sleepScore 또는 sleepTime 값
      ) {
    // ✅ 최대 값 설정 (수면 점수는 100, 수면 시간은 10시간)
    double maxValue = isSleepTime ? 10.0 : 100.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: SfCircularChart(
            series: <CircularSeries>[
              DoughnutSeries<_ChartData, String>(
                dataSource: [
                  _ChartData(label, sleepValue, color), // ✅ 수면 데이터 값
                  _ChartData("남은 부분", maxValue - sleepValue, Colors.grey.shade300), // ✅ 남은 부분
                ],
                xValueMapper: (_ChartData data, _) => data.category,
                yValueMapper: (_ChartData data, _) => data.value,
                pointColorMapper: (_ChartData data, _) => data.color,
                innerRadius: "70%",
                startAngle: 216,
                endAngle: 504,
              ),
            ],
          ),
        ),
        Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}


  Widget _buildChatbotComment(String comment) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ SomnUs AI Agent 타이틀 + 말풍선 아이콘 추가
          Row(
            children: [
              const Text(
                "SomnUs",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.chat_bubble_outline,
                color: Colors.black,
                size: 18,
              ),
              // 💬 말풍선 이모티콘
            ],
          ),
          const SizedBox(height: 8),

          // ✅ 챗봇 코멘트 표시
          Text(
            comment.isNotEmpty ? comment : "챗봇 피드백 없음",
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }


// ✅ 도넛형 차트 데이터 모델
class _ChartData {
  final String category;
  final double value;
  final Color color;

  _ChartData(this.category, this.value, this.color);
}
