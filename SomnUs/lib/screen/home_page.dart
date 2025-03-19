import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:somnus/model/sleep_today_data.dart';
import 'package:somnus/services/auth_service.dart';
import 'package:somnus/screen/report_page.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:somnus/screen/nfc_screen.dart';


// 월별 데이터 불러오기
Future<Map<DateTime, int>> fetchMonthlyData(String month) async {
  // month = '2025-02' 형태
  String? token = AuthService().getToken();

  if (token == null) {
    throw Exception("로그인이 필요합니다.");
  }

  final url = 'http://192.168.219.211:8001/sleep-data/calendar?date=$month';

  final response = await http.get(
    Uri.parse(url),
    headers: {'Authorization' : 'Bearer $token'}
  );

  if (response.statusCode == 200) {
    final decodeBody = utf8.decode(response.bodyBytes);
    final Map<String, dynamic> jsonResponse = json.decode(decodeBody);

    // 반환할 Map
    final Map<DateTime, int> dailyScores = {};

    // "calendar_data" 배열에서 각 항목 파싱
    if (jsonResponse.containsKey("calendar_data")) {
      for (var item in jsonResponse["calendar_data"]) {
        // item["date"]: "2025-03-01", item["sleep_score"]: 85
        final dateString = item["date"] as String;
        final sleepScore = item["sleep_score"] as int;

        DateTime dateTime = DateTime.parse(dateString);
        dailyScores[dateTime] = sleepScore;
      }
    }

    return dailyScores;
  } else {
    throw Exception("월별 수면 데이터를 불러오는데 실패했습니다. 상태코드: ${response.statusCode}");
  }
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NfcWebSocketService nfcWebSocketService;
  late Future<DailySleepDataResponse> futureSleepData;
  // 현재 포커스 된 달
  DateTime focusedMonth = DateTime.now();
  // API로 받아온 일자별 점수
  Map<DateTime, int> dailyScores = {};

  @override
  void initState() {
    super.initState();
    futureSleepData = fetchDailySleepData();
    _loadMonthlyData(focusedMonth);
    // 앱 실행 시 자동으로 WebSocket 연결 및 NFC 상태 수신 시작
    nfcWebSocketService = NfcWebSocketService();
    nfcWebSocketService.listenForNfc(context);

  }


  Future<void> _loadMonthlyData(DateTime month) async {
    final formattedMonth = DateFormat('yyyy.MM').format(month); // ex: "2025-03"
    try {
      final scores = await fetchMonthlyData(formattedMonth);
      setState(() {
        dailyScores = scores;
      });
      print(dailyScores); // 디버깅 출력
    } catch (e) {
      print(e);
    }
  }

  // 점수에 따른 색상 지정
  Color getScoreColor(int score) {
    if (score <= 25) {
      return Color(0xFFFF7675);
    } else if (score <= 50) {
      return Color(0xFFfdcb6e);
    } else if (score <= 75) {
      return Color(0xff55efc4);
    }else{
      return Color(0xff74b9ff);
    }
  }

  @override
  void dispose() {
    nfcWebSocketService.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<DailySleepDataResponse>(
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
            DailySleepData data = snapshot.data!.sleepData;
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
                    const SizedBox(height: 30),
        
                    const Text(
                      "수면 분석 및 통계",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
        
                    // ✅ 수면 분석 및 통계
                    _buildSleepStats(data),
                    const SizedBox(height: 20),
        
                    // ✅ 수면 캘린더
                    _buildSleepCalendar(),
                    const SizedBox(height: 20)
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 📌 수면 기록 테이블
  Widget _buildSleepStats(DailySleepData data) {
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

  // 📌 수면 캘린더 (월 변경 가능)
  Widget _buildSleepCalendar() {
    return TableCalendar(
      locale: 'ko_KR',   // 한글로 설정
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedMonth,
      calendarFormat: CalendarFormat.month,

      // 날짜 선택 시 ReportPage로 이동
      onDaySelected: (selectedDay, focusedDay) {
        String selectedDate = DateFormat('yyyy-MM-dd').format(selectedDay);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportPage(date: selectedDate, showBackButton: true,),
          ),
        );
      },

      // 달이 변경될 때 새로운 월 데이터 로드
      onPageChanged: (focusedDay) {
        setState(() {
          focusedMonth = focusedDay;
        });
        _loadMonthlyData(focusedMonth);
      },

      headerStyle: HeaderStyle(
        formatButtonVisible: false,   // 2weeks 숨김
        titleCentered: true,
      ),

      // 날짜 셀 커스터마이징
      calendarBuilders: CalendarBuilders(
        // 해당 오늘 날짜에 대한 효과 (점수 색깔, 수면 점수 나타내기)
        todayBuilder: (context, date, _) {
          final score = dailyScores[DateTime(date.year, date.month, date.day)];
          if (score != null){
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.blueAccent, width: 1)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // (1) 날짜 숫자
                  Text(
                    '${date.day}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black, // 날짜 색상
                    ),
                  ),
                  const SizedBox(height: 4),

                  // (2) 점수 + 색상 원
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 색상 원
                      Container(
                        width: 6,
                        height: 8,
                        decoration: BoxDecoration(
                          color: getScoreColor(score),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),

                      // 점수 텍스트
                      Text(
                        '$score점',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            // 점수가 없는 날짜
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: const TextStyle(fontSize: 14),
                ),
                // 아래 공간은 비워둠 (점수가 없으므로)
              ],
            );
          }
        },
        defaultBuilder: (context, date, _) {
          // 날짜만 비교할 수 있도록 year, month, day로 구성
          final score = dailyScores[DateTime(date.year, date.month, date.day)];
          if (score != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // (1) 날짜 숫자
                Text(
                  '${date.day}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black, // 날짜 색상
                  ),
                ),
                const SizedBox(height: 4),

                // (2) 점수 + 색상 원
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 색상 원
                    Container(
                      width: 6,
                      height: 8,
                      decoration: BoxDecoration(
                        color: getScoreColor(score),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),

                    // 점수 텍스트
                    Text(
                      '$score점',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            );
          } else {
            // 점수가 없는 날짜
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: const TextStyle(fontSize: 14),
                ),
                // 아래 공간은 비워둠 (점수가 없으므로)
              ],
            );
          }
        },
      ),
    );
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
          width: 172,
          height: 172,
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
