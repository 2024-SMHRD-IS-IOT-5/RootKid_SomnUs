import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:somnus/model/sleep_weekly_data.dart';

class WeeklySleepChart extends StatelessWidget {
  final WeeklySleepData data;
  final List<String> weekList; // 예: ["2월 4주차", "3월 1주차", ..., "4월 1주차"]
  final int selectedWeekIndex; // 예: 기본값 3 (3월 3주차)
  final void Function(int) onChangeWeek; // -1 또는 +1 전달
  final List<String> chatbotResponse;

  const WeeklySleepChart({
    Key? key,
    required this.data,
    required this.weekList,
    required this.selectedWeekIndex,
    required this.onChangeWeek,
    required this.chatbotResponse
  }) : super(key: key);

  /// 📌 주차 선택 버튼 위젯 (weekList와 selectedWeekIndex 사용)
  Widget _buildWeekSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => onChangeWeek(-1),
        ),
        Text(
          "25년 " + weekList[selectedWeekIndex],
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 30),
          onPressed: () => onChangeWeek(1),
        ),
      ],
    );
  }

  /// 📌 막대그래프 개별 바 생성
  List<BarChartGroupData> _getBarGroups() {
    final List<String> sleepTimes = [
      data.mon_time,
      data.tue_time,
      data.wed_time,
      data.thu_time,
      data.fri_time,
      data.sat_time,
      data.sun_time,
    ];

    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: _convertSleepTimeToDouble(sleepTimes[index]),
            color: Color(0xff141932),
            width: 16,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      );
    });
  }

  /// 📌 막대그래프 데이터 구성
  BarChartData _buildBarChart() {
    return BarChartData(
      barGroups: _getBarGroups(),
      titlesData: _getTitles(
        showBottom: true,
        showLeft: true,
        showRight: false,
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: false,
        drawHorizontalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
        },
      ),
      barTouchData: BarTouchData(enabled: false),
      alignment: BarChartAlignment.center,
    );
  }

  /// 📌 선그래프 데이터 구성
  LineChartData _buildLineChart() {
    final List<int> scores = [
      data.mon_score,
      data.tue_score,
      data.wed_score,
      data.thu_score,
      data.fri_score,
      data.sat_score,
      data.sun_score,
    ];

    return LineChartData(
      minX: -3,
      maxX: 6.63,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            7,
            (index) => FlSpot(index.toDouble(), scores[index].toDouble()),
          ),
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
      titlesData: _getTitles(
        showBottom: false,
        showLeft: false,
        showRight: true,
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
      lineTouchData: LineTouchData(enabled: true),
    );
  }

  /// 📌 축 타이틀 설정
  FlTitlesData _getTitles({
    required bool showBottom,
    required bool showLeft,
    required bool showRight,
  }) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showLeft,
          interval: 2,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                "${value.toInt()}시간",
                style: const TextStyle(fontSize: 12),
              ),
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
              child: Text(
                "${value.toInt()}점",
                style: const TextStyle(fontSize: 10),
              ),
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
                child: Text(
                  days[value.toInt()],
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  /// 📌 수면 시간을 숫자로 변환 (예: "6시간 30분" → 6.5)
  double _convertSleepTimeToDouble(String timeString) {
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

  /// 📌 범례 (Legend)
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 주차 선택 버튼 추가
        _buildWeekSelector(),
        const SizedBox(height: 5),
        const SizedBox(height: 20),
        // 막대그래프 + 선그래프 겹치기
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
        _buildLegend(),
        const SizedBox(height: 30),
        // 평균 수면 점수 표시
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text("평균 점수", style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 30),
        // 평균 수면 시간 표시
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
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "평균 수면시간",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                "${data.avg_sleep_time}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        _buildChatbotResponse(chatbotResponse),
      ],
    );
  }

  Widget _buildChatbotResponse(List<String> chatbotResponse) {
    List<String> themes = ["한 주 요약", "이번 주 특이사항", "개선사항"];

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: List.generate(themes.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✔️ 체크 아이콘 + 제목
                Row(
                  children: [
                    const Icon(Icons.check, color: Colors.black, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      themes[index],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5), // 텍스트와 챗봇 응답 사이 간격

                // 🔹 챗봇 응답 추가 (내용이 있다면 표시)
                if (index < chatbotResponse.length)
                  Text(
                    chatbotResponse[index],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
