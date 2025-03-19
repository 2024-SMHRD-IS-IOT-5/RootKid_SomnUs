import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:somnus/model/sleep_monthly_data.dart';


class MonthlySleepChart extends StatefulWidget {
  final SleepDataMonthly data;

  const MonthlySleepChart({Key? key, required this.data}) : super(key: key);

  @override
  _MonthlySleepChartState createState() => _MonthlySleepChartState();
}

class _MonthlySleepChartState extends State<MonthlySleepChart> {
  int selectedMonthIndex = 1; // ✅ 기본값 (2월)

  final List<String> monthList = [
    "1월", "2월", "3월", "4월", "5월", "6월",
    "7월", "8월", "9월", "10월", "11월", "12월"
  ];

  /// ✅ 월 변경 함수 (데이터는 변경하지 않음)
  void onChangeMonth(int offset) {
    setState(() {
      selectedMonthIndex =
          (selectedMonthIndex + offset) % 12; // 12개월 순환
      if (selectedMonthIndex < 0) {
        selectedMonthIndex += 12;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ 월 선택 버튼 추가
        _buildMonthSelector(),
        const SizedBox(height: 10),
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
        _buildSleepStats(),
        const SizedBox(height: 30),
        _buildSummaryCards(),
      ],
    );
  }

  // 막대그래프
  BarChartData _buildBarChart() {
    return BarChartData(
      barGroups: _getBarGroups(),
      titlesData: _getTitles(showBottom: true, showLeft: true, showRight: false),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: false,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          );
        },
      ),
      barTouchData: BarTouchData(enabled: true),
      alignment: BarChartAlignment.spaceAround,
    );
  }

  // 선 그래프
  LineChartData _buildLineChart() {
    final List<int> scores = [
      widget.data.w1_score, widget.data.w2_score, widget.data.w3_score,
      widget.data.w4_score
    ];

    return LineChartData(
      minX: -1.2,
      maxX: 3.9,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(4, (index) => FlSpot(index.toDouble(), scores[index].toDouble())),
          isCurved: false,
          color: Colors.red,
          dotData: FlDotData(show: true),
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      ],
      titlesData: _getTitles(showBottom: false, showLeft: false, showRight: true),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
      lineTouchData: LineTouchData(enabled: true),
    );
  }

  FlTitlesData _getTitles({required bool showBottom, required bool showLeft, required bool showRight}) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showLeft,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text("${value.toInt()}시간", style: const TextStyle(fontSize: 12)),
            );
          },
          interval: 2,
        ),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showRight,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("${value.toInt()}점", style: const TextStyle(fontSize: 12)),
            );
          },
          interval: 20,
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showBottom,
          getTitlesWidget: (value, meta) {
            const List<String> weeks = ["1주차", "2주차", "3주차", "4주차"];
            if (value.toInt() >= 0 && value.toInt() < weeks.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(weeks[value.toInt()], style: const TextStyle(fontSize: 14)),
              );
            }
            return const SizedBox();
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    final List<String> sleepTimes = [
      widget.data.w1_time, widget.data.w2_time, widget.data.w3_time,
      widget.data.w4_time, widget.data.w5_time
    ];

    return List.generate(5, (index) {
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

  Widget _buildSleepStats() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _circularStatCard("이번달 최저 점수", widget.data.min_sleep_score),
            _circularStatCard("평균 점수", widget.data.avg_sleep_score),
            _circularStatCard("이번달 최고 점수", widget.data.max_sleep_score),
          ],
        ),
        const SizedBox(height: 30),
        _buildNumericStats(),
      ],
    );
  }

  Widget _circularStatCard(String label, int value) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: value / 100,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade300,
                color: Colors.black,
              ),
            ),
            Text("$value", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildNumericStats() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          _statRow("최고 수면시간", widget.data.max_sleep_time),
          _divider(),
          _statRow("평균 수면시간", widget.data.avg_sleep_time),
          _divider(),
          _statRow("최저 수면시간", widget.data.min_sleep_time),
        ],
      ),
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

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: _boxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✔ 아이콘과 제목
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

                // 🔹 Chatbot 응답 내용 추가
                Text(
                  widget.data.chatbotResponse,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statRow(String label, String value) {
    return  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      );
  }

  /// 📌 **월 선택 버튼 UI**
  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => onChangeMonth(-1),
        ),
        Text(
          "25년 " + monthList[selectedMonthIndex], // ✅ 25년 고정 + 선택된 월 표시
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 30),
          onPressed: () => onChangeMonth(1),
        ),
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

