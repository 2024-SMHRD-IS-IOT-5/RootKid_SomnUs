import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ 오늘의 수면 요약
              const SleepSummaryWidget(),
              const SizedBox(height: 30),

              // ✅ 수면 점수 피드백
              _buildFeedbackCard(),
              const SizedBox(height: 30),

              // ✅ 수면 분석 및 통계 (바 차트)
              const Text("수면 분석 및 통계", style: _titleStyle),
              const SizedBox(height: 10),
              _buildSleepBarChart(),
            ],
          ),
        ),
      ),
    );
  }

  // 📌 수면 분석 차트 (Placeholder)
  Widget _buildSleepBarChart() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "📊 수면 분석 차트 (Bar Chart) 들어갈 자리",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }

  // 📌 피드백 카드
  Widget _buildFeedbackCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Somnus",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,)),
              const SizedBox(width: 5),
              const Icon(Icons.feedback_outlined, color: Colors.black, size: 22),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "수면점수가 80점이네요! 최고의 컨디션! 지금처럼 꾸준히 유지하면 건강한 수면 습관을 가질 수 있어요! 💪",
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // 📌 공통 스타일
  static const TextStyle _titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
}

// -----------------------------------------------------------
// ✅ 도넛형 수면 요약 차트 위젯 (하단 20% 비우기)
// -----------------------------------------------------------
class SleepSummaryWidget extends StatelessWidget {
  const SleepSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
            _buildSleepDurationChart(),
            _buildSleepScoreChart(),
          ],
        ),
      ],
    );
  }

  // 📌 수면 시간 도넛형 차트
  Widget _buildSleepDurationChart() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: SfCircularChart(
            series: <CircularSeries>[
              DoughnutSeries<_ChartData, String>(
                dataSource: [
                  _ChartData("수면", 80, Colors.blue),
                  _ChartData("남은 부분", 20, Colors.grey.shade300),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.nightlight_sharp, color: Colors.blue, size: 30),
            const SizedBox(height: 1),
            const Text(
              "9시간 11분",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Text(
              "00:13 ~ 09:24",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  // 📌 수면 점수 도넛형 차트
  Widget _buildSleepScoreChart() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: SfCircularChart(
            series: <CircularSeries>[
              DoughnutSeries<_ChartData, String>(
                dataSource: [
                  _ChartData("수면 점수", 80, Colors.green),
                  _ChartData("남은 부분", 20, Colors.grey.shade300),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("😀", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 1),
            const Text(
              "좋음",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 1),
            const Text("수면점수", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 1),
            const Text(
              "80점",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}

// ✅ 도넛형 차트를 위한 데이터 모델
class _ChartData {
  final String category;
  final double value;
  final Color color;

  _ChartData(this.category, this.value, this.color);
}
