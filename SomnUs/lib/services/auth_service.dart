import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://192.168.219.211:8001";
  // ✅ 토큰을 저장할 변수 (앱이 실행되는 동안 유지됨)
  static String? _token;
  static Map<String, dynamic>? _decodedToken;

  // ✅ 토큰 저장 및 디코딩 (로그인 성공 시 실행)
  void setToken(String token) {
    _token = token;
    _decodedToken = JwtDecoder.decode(token);
    print("토큰이 설정되었습니다: $_token");
    print("디코딩 결과: $_decodedToken");
  }

  // ✅ 현재 사용자가 부모 계정인지 확인
  bool isParent() {
    return _decodedToken != null && _decodedToken!['role'] == 'parent';
  }

  // 현재 사용자가 학생 계정인지 확인
  bool isStudent() {
    return _decodedToken != null && _decodedToken!['role'] == 'user';
  }



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
      print("로그인 실패 : 상태코드 ${response.statusCode}, 응답 ${response.body}");
      return false;
    }
  }

  // // ✅ 저장된 토큰 가져오기
  // String? getToken() {
  //   return _token;
  // }

  // ✅ 현재 저장된 토큰 반환
  String? getToken() => _token;

  // 사용자 정보 가져오기 - UserInfoPage에 필요한 메서드
  Future<Map<String, dynamic>> getUserInfo() async {
    if (_token == null) {
      throw Exception("로그인이 필요합니다");
    }

    print("getUserInfo 호출: 토큰 $_token 사용");

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/info"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token"
        },
      );

      print("API 응답 코드: ${response.statusCode}");
      print("API 응답 본문: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("사용자 정보를 가져오는데 실패했습니다 (상태 코드: ${response.statusCode})");
      }
    } catch (e) {
      print("getUserInfo 에러: $e");
      throw Exception("사용자 정보를 가져오는데 실패했습니다: $e");
    }
  }

  // 사용자 정보 업데이트 - UserInfoPage에 필요한 메서드
  Future<bool> updateUserInfo(Map<String, dynamic> userInfo) async {
    if (_token == null) {
      throw Exception("로그인이 필요합니다");
    }

    print("updateUserInfo 호출: 데이터 $userInfo");

    try {
      final response = await http.put(
        Uri.parse("$baseUrl/user/update"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token"
        },
        body: jsonEncode(userInfo),
      );

      print("API 응답 코드: ${response.statusCode}");
      print("API 응답 본문: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("updateUserInfo 에러: $e");
      return false;
    }
  }
}

