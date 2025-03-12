import 'package:flutter/material.dart';
import 'package:somnus/screen/sleep_screen.dart';
// 여기서 fetchSleepData(), SleepData, SleepDataResponse 가져옴
// 필요하다면 Syncfusion Charts 등의 라이브러리 import 가능

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late Future<SleepDataResponse> futureReportData;
  String _selectedTab = "일"; // ✅ 기본 탭은 '일'

  @override
  void initState() {
    super.initState();
    // ✅ sleep_screen.dart에 정의된 함수 사용
    futureReportData = fetchSleepData();
  }

  // **(1) 일/주/월 버튼**
  Widget _buildTabButtons() {
    // 탭 목록
    final tabs = ["일", "주", "월"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: tabs.map((tab) {
        final bool isSelected = (tab == _selectedTab);
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTab = tab;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF141932) : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tab,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // **(2) 날짜/요일 표시**
  Widget _buildDateInfo(SleepData data) {
    // 예시: "2월 12일 월요일" → 실제로는 date에 맞춰 요일 계산 필요
    // 여기서는 임시로 data.date가 "2025-02-12" 형태라고 가정
    // 예시: "2025-02-12"
    // 간단히 substring해서 "2월 12일"만 표시하거나,
    // DateTime 파싱 후 weekday에 따라 "월/화/수" 매핑

    // 임시 예시 파싱:
    final dateStr = data.date; // "2025.02.09" 형태라면...
    // 실제 로직: dateStr.split('.') → [2025, 02, 09]
    // 요일 계산은 DateTime.parse("2025-02-09") 사용

    return Column(
      children: [
        Text(
          // 예시: "2월 12일 월요일"
          // 실제로는 날짜 파싱 로직 필요
          dateStr.replaceAll("-", ".") + " (가상 요일)",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          // ex) "REM 수면 5시간 2분", "얕은 수면 3시간 20분" ...
          // 여기서는 임시로 startDt ~ endDt 만 표시
          "${data.startDt} ~ ${data.endDt}",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // **(3) 수면 세부 데이터 (REM/얕은/깊은/일어난 시간 등)**
  Widget _buildSleepDetails(SleepData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 예시: "REM 수면: 5시간 2분" → data.remSleep
        Text("REM 수면: ${data.remSleep}", style: const TextStyle(fontSize: 16)),
        Text("얕은 수면: ${data.lightSleep}", style: const TextStyle(fontSize: 16)),
        Text("깊은 수면: ${data.deepSleep}", style: const TextStyle(fontSize: 16)),
        // 일어난 시간: endDt
        Text("일어난 시간: ${data.endDt}", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
      ],
    );
  }

  // **(4) 원형 그래프 2개 (수면시간, 수면점수) → Placeholder**
  Widget _buildCircleGraphs(SleepData data) {
    // data.sleepTime 예: "9시간 11분"
    // data.sleepScore 예: 80
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // (좌) 수면시간 원형
        Column(
          children: [
            // 원형 placeholder
            Stack(
              alignment: Alignment.center,
              children: [
                const CircleAvatar(radius: 40, backgroundColor: Colors.grey),
                Text(data.sleepTime, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 5),
            const Text("수면 시간", style: TextStyle(fontSize: 14)),
          ],
        ),
        // (우) 수면점수 원형
        Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                const CircleAvatar(radius: 40, backgroundColor: Colors.grey),
                Text("${data.sleepScore}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 5),
            const Text("수면 점수", style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  // **(5) 추가 측정 항목 예시 (심박수, 코골이, 호흡수) → 임시 Placeholder**
  Widget _buildExtraData() {
    // 실제 data 모델에 없는 항목이라 Placeholder
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        Text("심박수: 58bpm", style: TextStyle(fontSize: 16)),
        Text("코골이: 21분", style: TextStyle(fontSize: 16)),
        Text("호흡수: 10회", style: TextStyle(fontSize: 16)),
      ],
    );
  }

  // **(6) 특이사항 종합 (챗봇 응답)**
  Widget _buildChatbotFeedback(String chatbotResponse) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "특이사항 종합:\n\n$chatbotResponse",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // **(7) 전체 UI 구성**
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar, BottomNavigationBar는 이미 MainNavigation에서 고정된다고 가정
      body: FutureBuilder<SleepDataResponse>(
        future: futureReportData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("에러: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("데이터가 없습니다."));
          }

          final SleepDataResponse responseData = snapshot.data!;
          final SleepData data = responseData.sleepData;
          final String chatbotResponse = responseData.chatbotResponse;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // (1) 일/주/월 버튼
                _buildTabButtons(),
                const SizedBox(height: 20),

                // (2) 날짜/요일
                _buildDateInfo(data),
                const SizedBox(height: 20),

                // (3) 세부 데이터
                _buildSleepDetails(data),
                const SizedBox(height: 10),

                // (4) 원형 그래프 2개 (수면시간 / 수면점수)
                _buildCircleGraphs(data),
                const SizedBox(height: 20),

                // (5) 추가 항목 예시
                _buildExtraData(),
                const SizedBox(height: 20),

                // (6) 특이사항 종합 (챗봇 응답)
                _buildChatbotFeedback(chatbotResponse),
              ],
            ),
          );
        },
      ),
    );
  }
}
