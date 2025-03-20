import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:somnus/screen/login_page.dart';
import 'package:somnus/services/auth_service.dart';

class ParentSignupPage extends StatefulWidget {
  const ParentSignupPage({Key? key}) : super(key: key);

  @override
  _ParentSignupPageState createState() => _ParentSignupPageState();
}

class _ParentSignupPageState extends State<ParentSignupPage> {
  final AuthService _authService = AuthService();

  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _registerParent() async {
    // ✅ 입력값 검증
    if (_studentIdController.text.isEmpty ||
        _idController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "모든 필드를 입력해주세요.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      Fluttertoast.showToast(
        msg: "비밀번호가 일치하지 않습니다.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    // ✅ FastAPI 서버에 회원가입 요청
    bool isRegistered = await _authService.registerParent(
      _studentIdController.text,
      _idController.text,
      _passwordController.text,
    );

    if (isRegistered) {
      Fluttertoast.showToast(msg: "회원가입 성공!", gravity: ToastGravity.BOTTOM);

      // ✅ 로그인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      Fluttertoast.showToast(
        msg: "회원가입 실패.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141932),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // 제목
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Spacer(),
                const Text(
                  '회원가입(학부모)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
            const SizedBox(height: 40),

            // 자녀 아이디 입력 필드
            const Text('자녀 아이디', style: _labelStyle),
            _buildInputField(
              controller: _studentIdController,
              hint: '자녀의 아이디를 입력해주세요',
            ),

            const SizedBox(height: 20),

            // 아이디 입력 필드
            const Text('아이디', style: _labelStyle),
            _buildInputField(controller: _idController, hint: '아이디를 입력해주세요'),

            const SizedBox(height: 20),

            // 비밀번호 입력 필드
            const Text('비밀번호', style: _labelStyle),
            _buildInputField(
              controller: _passwordController,
              hint: '비밀번호를 입력해주세요',
              isPassword: true,
            ),

            const SizedBox(height: 20),

            // 비밀번호 확인 필드
            const Text('비밀번호 확인', style: _labelStyle),
            _buildInputField(
              controller: _confirmPasswordController,
              hint: '비밀번호를 확인해주세요',
              isPassword: true,
            ),

            const SizedBox(height: 40),

            // 확인 버튼 (FastAPI 저장 + 로그인 페이지 이동)
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 50,
                  ),
                  backgroundColor: const Color(0xFF7D848D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: _registerParent, // ✅ 서버 요청 실행
                child: const Text(
                  '확인',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
  );

  // **📌 텍스트 입력 필드 위젯**
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.5), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
