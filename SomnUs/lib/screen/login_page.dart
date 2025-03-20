// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:somnus/screen/join_start.dart';
// import 'package:somnus/screen/main_navigation.dart';
// import 'package:somnus/services/auth_service.dart';
// import 'package:somnus/services/websocket_service.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _idController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final AuthService _authService = AuthService();
//   final WebSocketService _webSocketService = WebSocketService();
//
//   // ✅ 로그인 함수 (토큰 저장 추가)
//   void _login() async {
//     String? token = await _authService.loginUser(
//       _idController.text,
//       _passwordController.text,
//     );
//
//     if (token != null) {
//       print("로그인 성공! 토큰 저장 중...");
//
//       // ✅ SharedPreferences에 토큰 저장
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString("jwt_token", token);
//
//       // ✅ WebSocket 연결
//       _webSocketService.connect(token);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("로그인 성공!")),
//       );
//
//       // ✅ 로그인 성공 시 MainNavigation으로 이동 (이전 로그인 페이지는 스택에서 제거)
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const MainNavigation()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("로그인 실패: 아이디 또는 비밀번호가 올바르지 않습니다.")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF141932),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               "images/somnus.png",
//               width: 180,
//               height: 180,
//               fit: BoxFit.contain,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               "S O M N U S",
//               style: TextStyle(color: Colors.white, fontSize: 32),
//             ),
//             const SizedBox(height: 80),
//
//             _buildTextField(controller: _idController, hintText: "아이디를 입력해주세요"),
//             const SizedBox(height: 10),
//             _buildTextField(
//               controller: _passwordController,
//               hintText: "비밀번호를 입력해주세요",
//               isPassword: true,
//             ),
//             const SizedBox(height: 40),
//
//             _buildButton(
//               text: "로그인",
//               color: const Color(0xFF7D848D),
//               onPressed: _login,
//             ),
//             const SizedBox(height: 15),
//             _buildButton(
//               text: "회원가입",
//               color: const Color(0xFF5E86B4),
//               onPressed: () {
//                 // ✅ 회원가입 페이지로 이동
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const JoinStartPage(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hintText,
//     bool isPassword = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 40),
//       child: TextField(
//         controller: controller,
//         obscureText: isPassword,
//         decoration: InputDecoration(
//           hintText: hintText,
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildButton({
//     required String text,
//     required Color color,
//     required VoidCallback onPressed,
//   }) {
//     return SizedBox(
//       width: 230,
//       height: 45,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(50),
//           ),
//         ),
//         onPressed: onPressed,
//         child: Text(
//           text,
//           style: const TextStyle(fontSize: 20, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:somnus/screen/home_page.dart';
import 'package:somnus/screen/join_start.dart';
import 'package:somnus/screen/main_navigation.dart';
import 'package:somnus/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // ✅ 로그인 함수
  void _login() async {
    bool isSuccess = await _authService.loginUser(
      _idController.text,
      _passwordController.text,
    );

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인 성공!")),
      );

      // ✅ 로그인 성공 시 MainNavigation으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation(),)
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인 실패: 아이디 또는 비밀번호 오류")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF141932),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          // 화면 높이만큼은 최소로 차지하도록 지정
          constraints: BoxConstraints(
            minHeight: mediaQuery.size.height,
          ),
          // 자식의 높이를 계산해주는 IntrinsicHeight
          child: IntrinsicHeight(
            child: Column(
              // 내용물을 세로축 중앙에 배치
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 상단 여백 등 필요하다면 추가
                const SizedBox(height: 40),

                Image.asset(
                  "images/somnus.png",
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  "S O M N U S",
                  style: TextStyle(color: Colors.white, fontSize: 32),
                ),
                const SizedBox(height: 80),

                _buildTextField(controller: _idController, hintText: "아이디를 입력해주세요"),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _passwordController,
                  hintText: "비밀번호를 입력해주세요",
                  isPassword: true,
                ),
                const SizedBox(height: 40),

                _buildButton(
                  text: "로그인",
                  color: const Color(0xFF7D848D),
                  onPressed: _login,
                ),
                const SizedBox(height: 15),
                _buildButton(
                  text: "회원가입",
                  color: const Color(0xFF5E86B4),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JoinStartPage(),
                      ),
                    );
                  },
                ),

                // 하단 여백 등 필요하다면 추가
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 230,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}

