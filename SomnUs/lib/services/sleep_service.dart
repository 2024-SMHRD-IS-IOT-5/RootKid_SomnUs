import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';  // ✅ JWT 토큰 저장용
import 'package:somnus/config/config.dart';

class SleepService {
  final String baseUrl = "${Config.baseUrl}";  // FastAPI 서버 주소

  Future<Map<String, dynamic>> fetchSleepData(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("jwt_token");  // ✅ 저장된 JWT 토큰 가져오기

    if (token == null) {
      throw Exception("로그인이 필요합니다.");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/sleep-data'),
      headers: {"Authorization": "Bearer $token"},  // ✅ JWT 토큰 포함
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("수면 데이터를 불러오는 데 실패했습니다.");
    }
  }
}
