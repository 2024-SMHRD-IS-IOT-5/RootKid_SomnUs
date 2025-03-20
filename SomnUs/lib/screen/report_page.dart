import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:somnus/model/sleep_daily_data.dart';
import 'package:somnus/model/sleep_weekly_data.dart';
import 'package:somnus/screen/sleep_weekly_screen.dart';
import 'package:somnus/model/sleep_monthly_data.dart';
import 'package:somnus/screen/sleep_monthly_screen.dart';
import 'package:somnus/services/auth_service.dart';


class ReportPage extends StatefulWidget {
  final String date;
  final bool showBackButton; // 뒤로가기 버튼 표시 여부 추가
  const ReportPage({Key? key, required this.date, this.showBackButton = false}) : super(key:key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late DateTime selectedDate; // 초기 날짜
  String selectedReportType = "일"; // 기본값: 일간 보고서
  late ScrollController _scrollController;
  bool _isAppBarVisible = true;


  late Future<DailySleepDataResponse> futureSleepData; // ✅ sleep_screen.dart에서 API 호출
  late Future<WeeklySleepDataResponse> futureWeeklySleepData;
  late Future<MonthlySleepDataResponse> futureMonthlyData;

  final List<String> weekList = [
    "2월 1주차",
    "2월 2주차",
    "2월 3주차",
    "2월 4주차",
    "3월 1주차",
    "3월 2주차",
    "3월 3주차",  // 기본값 index=3

  ];

  int selectedWeekIndex = 5; // 기본값 3월 3주차


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    // ✅ API 요청을 초기 날짜에 맞춰서 수행
    futureSleepData = fetchDailySleepData(widget.date);
    selectedDate = DateFormat("yyyy-MM-dd").parse(widget.date);
    // 초기날짜를 위젯의 date값으로 설정
    String dateStr = DateFormat("yyyy-MM-dd").format(selectedDate);
    futureWeeklySleepData = fetchWeeklySleepData(weekList[selectedWeekIndex]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isAppBarVisible) {
        setState(() {
          _isAppBarVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward ||
        _scrollController.position.pixels <= 50) {
      if (!_isAppBarVisible) {
        setState(() {
          _isAppBarVisible = true;
        });
      }
    }
  }
  /// ✅ 날짜 변경 (일간))
  void _changeDate(int offset) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: offset));
      String dateStr = DateFormat("yyyy-MM-dd").format(selectedDate);
      futureSleepData = fetchDailySleepData(dateStr); // ✅ 날짜 변경 후 API 다시 호출
    });
  }


  // ✅ 오전/오후를 구분하여 HH:MM 형식으로 변환
  String formatTime(String time) {
    List<String> parts = time.split(":");
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    // 오전/오후 구분
    String period = hours < 12 ? "오전" : "오후";

    // 12시간제 변환 (12시는 그대로 유지)
    int displayHours = hours % 12 == 0 ? 12 : hours % 12;

    // HH:MM 형식으로 반환
    return "$period ${displayHours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
  }

// ✅ 초(seconds)를 분(minutes)으로 변환하여 "MM분" 형식으로 출력
  String formatSecondsToMinutes(String seconds) {
    int sec = int.parse(seconds);
    int minutes = (sec / 60).floor();

    // 2자리로 맞추기
    return minutes.toString().padLeft(2, '0') + "분";
  }

  // 수면 시간 그래프에 나타내기 위해 소수점으로 변경
  double parseSleepTime(String timeString) {
    RegExp regex = RegExp(r'(\d+)시간\s*(\d*)분*');
    Match? match = regex.firstMatch(timeString);

    if (match != null) {
      double hours = double.parse(match.group(1) ?? "0");
      double minutes =
          match.group(2)?.isNotEmpty == true
              ? double.parse(match.group(2)!) / 60.0
              : 0.0;
      return hours + minutes;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat("M월 d일 EEEE", "ko_KR").format(selectedDate);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ReportPage 전용 뒤로가기 버튼 영역(조건부 표시)
          if (widget.showBackButton)
            SafeArea(
              child: Row(
                children: [IconButton(onPressed: (){
                  Navigator.pop(context);
                }, icon: const Icon(Icons.arrow_back))]
              ),
            ),
          //  (2) 일 주 월 버튼 (AnimatedContainer)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isAppBarVisible ? 60 : 0,
            child: _buildReportTypeSelector(),
          ),
          // (3) Expanded 영역에서 SingleChildScrollView
          Expanded(
            child: FutureBuilder<DailySleepDataResponse>(
              future: futureSleepData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('에러: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('수면 데이터 없음'));
                }

                final DailySleepData data = snapshot.data!.sleepData;
                final String chatbotResponse = snapshot.data!.chatbotResponse;
                selectedDate = DateFormat("yyyy년 MM월 dd일", "ko_KR").parse(data.date); // API에서 받은 날짜 적용

                return SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedReportType == "일") _buildDateSelector(formattedDate),
                      const SizedBox(height: 20),
                      _buildSelectedReport(data, chatbotResponse),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// **📌 상단 '일 / 주 / 월' 선택 버튼 (고정)**
  Widget _buildReportTypeSelector() {
    final reportTypes = ["일", "주", "월"];
    return Container(
      width: double.infinity,
      height: 60,
      color: Colors.white,
      child: Center(
        child: Container(
          width: 200,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF141932),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                reportTypes.map((type) {
                  final bool isSelected = (type == selectedReportType);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedReportType = type;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  /// **📌 날짜 선택 버튼 (이전/다음 날짜 이동)**
  Widget _buildDateSelector(String formattedDate) {
    String formattedDate = DateFormat(
      "M월 d일 EEEE",
      "ko_KR",
    ).format(selectedDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => _changeDate(-1),
        ),
        Text(
          formattedDate,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 30),
          onPressed: () => _changeDate(1),
        ),
      ],
    );
  }

  /// **📌 선택된 보고서에 따라 적절한 화면 표시**
  Widget _buildSelectedReport(DailySleepData data, String chatbotResponse) {
    switch (selectedReportType) {
      case "일":
        return _buildDailyReport(data, chatbotResponse);
      case "주":
        return FutureBuilder<WeeklySleepDataResponse>(
          future: fetchWeeklySleepData(weekList[selectedWeekIndex]), // ✅ 주간 데이터 API 호출
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('에러 발생: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text("수면 데이터 없음"));
            }

            WeeklySleepData sleepData = snapshot.data!.sleepData; // ✅ 데이터 가져오기
            List<String> chatbotResponseList = snapshot.data!.chatbotResponse;
            return SingleChildScrollView(
              controller: _scrollController,
              child: WeeklySleepChart(
                  data : sleepData,
              weekList: weekList,  // ReportPage에 정의된 주차 리스트
              selectedWeekIndex: selectedWeekIndex,
              chatbotResponse : chatbotResponseList,
              onChangeWeek: (int offset){
                    setState(() {
                      int newIndex = selectedWeekIndex + offset;
                      if (newIndex >= 0 && newIndex < weekList.length){
                        selectedWeekIndex = newIndex;
                      }
                    });
              },),
            ); // ✅ `WeeklySleepScreen`을 사용
          },
        );
      case "월":
        return FutureBuilder<MonthlySleepDataResponse>(
          future: fetchMonthlySleepData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('에러 발생: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text("수면 데이터 없음"));
            }
            SleepDataMonthly sleepData = snapshot.data!.sleepData;
            return SingleChildScrollView(
              controller: _scrollController,
                child: MonthlySleepChart(data: sleepData));
          },
        );
      default:
        return _buildDailyReport(data, chatbotResponse);
    }
  }


  /// **📌 일간 보고서**
  Widget _buildDailyReport(DailySleepData data, String chatbotResponse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _buildSleepCharts(data),
        const SizedBox(height: 40),
        _buildAdditionalMetrics(chatbotResponse,data),
        const SizedBox(height: 20),
        _buildSleepStats(data),
        const SizedBox(height: 30),
      ],
    );
  }

  /// **📌 수면 데이터 박스**
  Widget _buildSleepStats(DailySleepData data) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          _buildStatRow("REM 수면", data.remSleep),
          _divider(),
          _buildStatRow("얕은 수면", data.lightSleep),
          _divider(),
          _buildStatRow("깊은 수면", data.deepSleep),
          _divider(),
          _buildStatRow("잠든 시간", formatTime(data.startDt)),
          _divider(),
          _buildStatRow("일어난 시간", formatTime(data.endDt)),
        ],
      ),
    );
  }

  /// **📌 원형 그래프**
  Widget _buildSleepCharts(DailySleepData data) {
    double sleepValue = parseSleepTime(data.sleepTime);
    sleepValue =
        sleepValue.isNaN || sleepValue.isInfinite ? 0.0 : sleepValue; // 예외 처리

    double sleepScoreValue = (data.sleepScore ?? 0).toDouble(); // null 방지

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSleepScoreChart(
          "수면 시간",
          data.sleepTime,
          ((sleepValue / 10) * 100).toInt(),
          const Color(0xFF141932),
        ),
        _buildSleepScoreChart(
          "수면 점수",
          "${data.sleepScore}점",
          sleepScoreValue.toInt(),
          const Color(0xFF141932),
        ),
      ],
    );
  }

  /// **📌 원형 그래프 UI**
  Widget _buildSleepScoreChart(
    String label,
    String value,
    int percentage,
    Color color,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade300,
                color: color,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  /// **📌 심박수, 코골이, 호흡수 + 특이사항 추가**
  Widget _buildAdditionalMetrics( String chatbotResponse,DailySleepData data) {
    return Column(
      children: [
        _buildChatbotComment(chatbotResponse),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: _boxDecoration(),
          child: Column(
            children: [
              _buildStatRow("평균 심박수", "${data.hr_average} bpm"),
              _divider(),
              _buildStatRow("분당 호흡수", "${data.rr_average}회"),
              _divider(),
              _buildStatRow("코골이", formatSecondsToMinutes(data.snoring)),
            ],
          ),
        ),
      ],
    );
  }

  /// **📌 특이사항 종합 (챗봇 코멘트)**
  Widget _buildChatbotComment(String comment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 (✔ 아이콘 포함)
          Row(
            children: [
              const Icon(Icons.check, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              const Text(
                "특이사항 종합",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 챗봇 응답 내용
          Text(
            comment,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
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
    );
  }

  Widget _divider() => Divider(color: Colors.black.withOpacity(0.2));

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: Colors.black.withOpacity(0.2)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 4,
        offset: const Offset(2, 2),
      ),
    ],
  );
}
