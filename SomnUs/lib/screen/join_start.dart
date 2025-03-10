import 'package:flutter/material.dart';
import 'student_signup_page.dart'; // 학생 회원가입 페이지 import
import 'parent_signup_page.dart'; // 학부모 회원가입 페이지 import

class JoinStartPage extends StatelessWidget {
  const JoinStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141932),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141932), // 배경색 동일하게 설정
        elevation: 0, // 그림자 없애기
        leading: Padding(
          padding: const EdgeInsets.only(left: 16), // 아이콘을 오른쪽으로 이동
          child: IconButton(
            icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
            // 뒤로 가기 아이콘
            onPressed: () {
              Navigator.pop(context); // 이전 화면으로 돌아가기
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 60), // ✅ 전체적으로 위로 올리기
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // ✅ 상단 정렬
            children: [
              // 안내 텍스트
              const Text(
                "회원가입 유형을 선택하세요",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30), // ✅ 텍스트 아래 여백 추가 (위로 이동)
              // 학부모 선택 버튼
              _buildSelectionBox(
                context: context,
                imagePath: "images/parents.png",
                label: "학부모",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ParentSignupPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30), // ✅ 학부모 선택과 학생 선택 간격 줄이기
              // 학생 선택 버튼
              _buildSelectionBox(
                context: context,
                imagePath: "images/students.png",
                label: "학생",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentSignupPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 학부모 & 학생 선택 박스
  Widget _buildSelectionBox({
    required BuildContext context,
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 270,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 120, height: 120), // 아이콘 이미지
            const SizedBox(height: 20),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
