import 'package:flutter/material.dart';

class SleepMonthlyScreen extends StatelessWidget {
  const SleepMonthlyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("월간 보고서")),
      body: const Center(
        child: Text("월간 수면 데이터 (추후 구현 예정)", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
