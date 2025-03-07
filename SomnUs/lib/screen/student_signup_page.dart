import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:somnus/screen/student_signup_info_page.dart';

class StudentSignupPage extends StatefulWidget {
  const StudentSignupPage({Key? key}) : super(key: key);

  @override
  _StudentSignupPageState createState() => _StudentSignupPageState();
}

class _StudentSignupPageState extends State<StudentSignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _goToStudentInfoPage() {
    if (_nameController.text.isEmpty ||
        _idController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "모든 필드를 입력해주세요.",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.redAccent,);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      Fluttertoast.showToast(msg: "비밀번호가 일치하지 않습니다.");
      return;
    }

    // ✅ 이름, 아이디, 비밀번호를 `student_signup_info_page.dart`로 전달
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => StudentInfoPage(
              id: _idController.text,
              password: _passwordController.text,
              name: _nameController.text,
            ),
      ),
    );
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
            // 뒤로가기 버튼 + 회원가입(학생) 제목
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
                  '회원가입(학생)',
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

            // 이름 입력 필드
            const Text('이름', style: _labelStyle),
            _buildInputField(controller: _nameController, hint: '이름을 입력해주세요'),

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

            // 다음 버튼
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
                onPressed: _goToStudentInfoPage,
                child: const Text(
                  '다음',
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
      child: TextField(
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
