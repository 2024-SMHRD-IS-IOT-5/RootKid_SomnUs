import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://192.168.219.211:8001";
  // ✅ 토큰을 저장할 변수 (앱이 실행되는 동안 유지됨)
  static String? _token;

  // ✅ 학생 회원가입 요청 (필드명 수정)
  Future<bool> registerStudent(String id, String password, String name, int age, int weight) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register/student"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,           // ✅ FastAPI에서 요구하는 필드명 사용
        "password": password,
        "name": name,
        "age": age,
        "weight": weight
      }),
    );

    return response.statusCode == 200;
  }

  // ✅ 학부모 회원가입 요청 (필드명 수정)
  Future<bool> registerParent(String studentId, String id, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register/parent"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "student_id": studentId,  // ✅ FastAPI에서 요구하는 필드명 사용
        "id": id,
        "password": password
      }),
    );

    return response.statusCode == 200;
  }


  // ✅ 로그인 요청 (토큰 저장)
  Future<bool> loginUser(String id, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data["access_token"]; // ✅ 토큰 저장
      return true;
    } else {
      return false;
    }
  }

  // ✅ 저장된 토큰 가져오기
  String? getToken() {
    return _token;
  }
}

