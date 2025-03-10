// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// // ✅ 수면 데이터 모델 정의
// class SleepData {
//   final String date;
//   final String startDt;
//   final String endDt;
//   final String sleepTime;
//   final String deepSleep;
//   final String lightSleep;
//   final String remSleep;
//   final int sleepScore;
//
//   SleepData({
//     required this.date,
//     required this.startDt,
//     required this.endDt,
//     required this.sleepTime,
//     required this.deepSleep,
//     required this.lightSleep,
//     required this.remSleep,
//     required this.sleepScore,
//   });
//
//   factory SleepData.fromJson(Map<String, dynamic> json) {
//     return SleepData(
//       date: json['date'],
//       startDt: json['startDt'],
//       endDt: json['endDt'],
//       sleepTime: json['sleep_time'],
//       deepSleep: json['deepsleep'],
//       lightSleep: json['lightsleep'],
//       remSleep: json['remsleep'],
//       sleepScore: json['sleep_score'],
//     );
//   }
// }
//
// // ✅ API 호출 함수 (토큰을 `SharedPreferences`에서 가져와 사용)
// Future<SleepData> fetchSleepData() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? token = prefs.getString("jwt_token");
//
//   if (token == null) {
//     throw Exception("로그인이 필요합니다.");
//   }
//
//   final response = await http.get(
//     Uri.parse('http://192.168.219.211:8001/sleep-data'),
//     headers: {'Authorization': 'Bearer $token'},
//   );
//
//   if (response.statusCode == 200) {
//     return SleepData.fromJson(json.decode(response.body));
//   } else {
//     throw Exception("수면 데이터를 불러오는데 실패했습니다. 응답: ${response.body}");
//   }
// }
//
// class SleepDataScreen extends StatefulWidget {
//   const SleepDataScreen({super.key});
//
//   @override
//   _SleepDataScreenState createState() => _SleepDataScreenState();
// }
//
// class _SleepDataScreenState extends State<SleepDataScreen> {
//   late Future<SleepData> futureSleepData;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSleepData();
//   }
//
//   // ✅ 저장된 토큰을 불러와 수면 데이터 요청
//   void _loadSleepData() {
//     setState(() {
//       futureSleepData = fetchSleepData();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("수면 데이터"),
//         backgroundColor: const Color(0xFF141932),
//         elevation: 2,
//       ),
//       body: Center(
//         child: FutureBuilder<SleepData>(
//           future: futureSleepData,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const CircularProgressIndicator();
//             } else if (snapshot.hasError) {
//               return Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.error, color: Colors.red, size: 40),
//                     const SizedBox(height: 10),
//                     Text(
//                       "에러 발생: ${snapshot.error}",
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(color: Colors.red, fontSize: 16),
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _loadSleepData,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blueAccent,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text("다시 시도", style: TextStyle(color: Colors.white)),
//                     ),
//                   ],
//                 ),
//               );
//             } else if (snapshot.hasData) {
//               SleepData data = snapshot.data!;
//               return Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Card(
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildSleepInfo("📅 날짜", data.date),
//                         _buildSleepInfo("🛏️ 수면 시작 시간", data.startDt),
//                         _buildSleepInfo("⏰ 수면 종료 시간", data.endDt),
//                         _buildSleepInfo("💤 총 수면 시간", data.sleepTime),
//                         _buildSleepInfo("🌙 깊은 수면", data.deepSleep),
//                         _buildSleepInfo("🌙 얕은 수면", data.lightSleep),
//                         _buildSleepInfo("🌙 REM 수면", data.remSleep),
//                         _buildSleepInfo("⭐ 수면 점수", "${data.sleepScore} 점"),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }
//             return Container();
//           },
//         ),
//       ),
//     );
//   }
//
//   // ✅ 수면 정보 위젯
//   Widget _buildSleepInfo(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5),
//       child: Row(
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 18, color: Colors.black54),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:somnus/services/auth_service.dart';

// ✅ 수면 데이터 모델 정의
class SleepData {
  final String date;
  final String startDt;
  final String endDt;
  final String sleepTime;
  final String deepSleep;
  final String lightSleep;
  final String remSleep;
  final int sleepScore;

  SleepData({
    required this.date,
    required this.startDt,
    required this.endDt,
    required this.sleepTime,
    required this.deepSleep,
    required this.lightSleep,
    required this.remSleep,
    required this.sleepScore,
  });

  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      date: json['date'],
      startDt: json['startDt'],
      endDt: json['endDt'],
      sleepTime: json['sleep_time'],
      deepSleep: json['deepsleep'],
      lightSleep: json['lightsleep'],
      remSleep: json['remsleep'],
      sleepScore: json['sleep_score'],
    );
  }
}


// ✅ API 호출 함수 (AuthService에서 토큰 가져오기)
Future<SleepData> fetchSleepData() async {
  String? token = AuthService().getToken(); // ✅ 로그인된 토큰 가져오기

  if (token == null) {
    throw Exception("로그인이 필요합니다.");
  }

  final response = await http.get(
    Uri.parse('http://192.168.219.211:8001/sleep-data'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return SleepData.fromJson(json.decode(response.body));
  } else {
    throw Exception("수면 데이터를 불러오는데 실패했습니다. 응답: ${response.body}");
  }
}

class SleepDataScreen extends StatefulWidget {
  const SleepDataScreen({super.key});

  @override
  _SleepDataScreenState createState() => _SleepDataScreenState();
}

class _SleepDataScreenState extends State<SleepDataScreen> {
  late Future<SleepData> futureSleepData;

  @override
  void initState() {
    super.initState();
    futureSleepData = fetchSleepData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("수면 데이터")),
      body: Center(
        child: FutureBuilder<SleepData>(
          future: futureSleepData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('에러: ${snapshot.error}');
            } else {
              SleepData data = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('날짜: ${data.date}'),
                  Text('수면 시간: ${data.sleepTime}'),
                  Text('수면 점수: ${data.sleepScore}'),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

