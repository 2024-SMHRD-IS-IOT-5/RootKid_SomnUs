import 'dart:async';
import 'package:flutter/material.dart';
import 'package:somnus/screen/login_page.dart'; // 로그인 화면 import

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 1.0;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      setState(() {
        _opacity = 0.0; // 점점 사라짐
        _scale = 1.2; // 점점 커짐
      });

      // 애니메이션이 끝난 후 로그인 화면으로 이동
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141932), // 배경색
      body: SafeArea(
        child: Center(
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: _opacity,
            child: AnimatedScale(
              duration: Duration(milliseconds: 500),
              scale: _scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고 이미지
                  SizedBox(
                    width: 97,
                    height: 97,
                    child: Image.asset('images/somnus.png'), // 이미지 로드
                  ),
                  const SizedBox(height: 37),

                  // 앱 이름
                  const Text(
                    'S O M N U S',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'JejuGothic',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
