import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:somnus/model/sleep_weekly_data.dart';

class WeeklySleepChart extends StatelessWidget {
  final WeeklySleepData data;

  const WeeklySleepChart({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),

        // ✅ 주차 정보
        Text(
          "${data.week_number}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        // ✅ 기간 표시
        const SizedBox(height: 5),
        Text(
          "2025.02.09 ~ 2025.02.15",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),

        const SizedBox(height: 20),

        // ✅ 차트 표시
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: _getBarGroups(),
              titlesData: _getTitles(),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
              barTouchData: BarTouchData(enabled: true),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ✅ 평균 수면 점수 표시
        Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: data.avg_sleep_score / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "${data.avg_sleep_score}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Text("평균 점수", style: TextStyle(fontSize: 16)),
          ],
        ),

        const SizedBox(height: 10),

        // ✅ 평균 수면 시간 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "평균 수면시간   ${data.avg_sleep_time}",
            style: const TextStyle(fontSize: 16),
          ),
        ),

        const SizedBox(height: 30),

        // ✅ 한 주에 대한 요약 & 특이사항
        _buildSummarySection(),
      ],
    );
  }

  /// 📌 주차별 평균 수면 점수 막대 그래프
  List<BarChartGroupData> _getBarGroups() {
    return [
      _buildBarGroup(0, data.mon_score.toDouble()),
      _buildBarGroup(1, data.tue_score.toDouble()),
      _buildBarGroup(2, data.wed_score.toDouble()),
      _buildBarGroup(3, data.thu_score.toDouble()),
      _buildBarGroup(4, data.fri_score.toDouble()),
      _buildBarGroup(5, data.sat_score.toDouble()),
      _buildBarGroup(6, data.sun_score.toDouble()),
    ];
  }

  /// 📌 개별 막대 바 생성
  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.black,
          width: 16,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  /// 📌 월~일 요일 타이틀 표시
  FlTitlesData _getTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            List<String> days = ["월", "화", "수", "목", "금", "토", "일"];
            return Text(days[value.toInt()], style: const TextStyle(fontSize: 14));
          },
        ),
      ),
    );
  }

  /// 📌 한 주 요약 & 특이사항 표시
  Widget _buildSummarySection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "✔ 한 주에 대한 요약",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "✔ 이번 주 특이사항",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("✔ 개선사항"),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}