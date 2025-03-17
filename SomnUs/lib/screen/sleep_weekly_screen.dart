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

        // ✅ 막대그래프 + 선그래프 겹치기
        AspectRatio(
          aspectRatio: 1.7,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                BarChart(_buildBarChart()),
                LineChart(_buildLineChart()),
              ],
            ),
          ),
        ),


        const SizedBox(height: 10),
        // ✅ 범례 (Legend)
        _buildLegend(),

        const SizedBox(height: 30),

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
            const SizedBox(height: 10),
            const Text("평균 점수", style: TextStyle(fontSize: 16)),
          ],
        ),

        const SizedBox(height: 30),

        // ✅ 평균 수면 시간 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                )
              ]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "평균 수면시간",
                style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w500),
              ),
              Text(
                "${data.avg_sleep_time}",
                style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  /// 📌 **막대그래프 (수면 시간)**
  BarChartData _buildBarChart() {
    return BarChartData(
      // 동일한 최소/최대 X 값으로 정확히 같은 영역 사용
      barGroups: _getBarGroups(),
      titlesData: _getTitles(showBottom: true, showLeft: true, showRight: false),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          );
        },
      ),
      barTouchData: BarTouchData(enabled: true),
      alignment: BarChartAlignment.center,
    );
  }

  /// 📌 **막대그래프 개별 바 생성**
  List<BarChartGroupData> _getBarGroups() {
    final List<String> sleepTimes = [
      data.mon_time, data.tue_time, data.wed_time,
      data.thu_time, data.fri_time, data.sat_time, data.sun_time
    ];

    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: _convertSleepTimeToDouble(sleepTimes[index]),
            color: Colors.black,
            width: 16,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      );
    });
  }

  /// 📌 **선그래프 (수면 점수)**
  LineChartData _buildLineChart() {
    final List<int> scores = [
      data.mon_score, data.tue_score, data.wed_score,
      data.thu_score, data.fri_score, data.sat_score, data.sun_score
    ];

    return LineChartData(
      // 동일한 최소/최대 X 값으로 정확히 같은 영역 사용
      minX: -3.1,
      maxX: 6.7,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(7, (index) => FlSpot(index.toDouble(), scores[index].toDouble())),
          isCurved: false,
          color: Colors.red,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.red,
                strokeWidth: 0,
                strokeColor: Colors.red,
              );
            },
          ),
          barWidth: 3,
          belowBarData: BarAreaData(show: false),
        ),
      ],
      titlesData: _getTitles(showBottom: false, showLeft: false, showRight: true),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: true),
      lineTouchData: LineTouchData(enabled: true),
    );
  }

  /// 📌 **X축(요일) 및 Y축(시간/점수) 타이틀 설정**
  FlTitlesData _getTitles({required bool showBottom, required bool showLeft, required bool showRight}) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showLeft,
          interval: 2,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text("${value.toInt()}시간", style: const TextStyle(fontSize: 12)),
            );
          },
          reservedSize: 40,
        ),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showRight,
          interval: 20,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("${value.toInt()}점", style: const TextStyle(fontSize: 10)),
            );
          },
          reservedSize: 40,
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showBottom,
          getTitlesWidget: (value, meta) {
            const List<String> days = ["월", "화", "수", "목", "금", "토", "일"];
            if (value.toInt() >= 0 && value.toInt() < days.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(days[value.toInt()], style: const TextStyle(fontSize: 14)),
              );
            }
            return const SizedBox();
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  /// 📌 **범례 (Legend)**
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.black, "수면 시간"),
        const SizedBox(width: 20),
        _legendItem(Colors.red, "수면 점수"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  /// 📌 **수면 시간을 숫자로 변환 (예: "6시간 30분" → 6.5)**
  double _convertSleepTimeToDouble(String timeString) {
    RegExp regex = RegExp(r'(\d+)시간\s*(\d*)분*');
    Match? match = regex.firstMatch(timeString);
    if (match != null) {
      double hours = double.parse(match.group(1) ?? "0");
      double minutes = match.group(2)?.isNotEmpty == true ? double.parse(match.group(2)!) / 60.0 : 0.0;
      return hours + minutes;
    }
    return 0.0;
  }
}