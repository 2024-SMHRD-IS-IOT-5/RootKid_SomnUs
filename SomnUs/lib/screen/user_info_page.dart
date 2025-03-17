import 'package:flutter/material.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  // 초기 사용자 정보
  String userId = "smhrd";
  String userName = "우용";
  String password = "password123"; // 실제 앱에서는 비밀번호를 수정할 수 없게 하거나 별도의 페이지로 처리
  String birthDate = "1993-11-02";
  double weight = 73.0;

  // 텍스트 필드 상태 (편집 가능)
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  bool isEditing = false; // 편집 모드 상태

  @override
  void initState() {
    super.initState();
    // 초기값으로 사용자 정보를 텍스트 필드에 설정
    userNameController.text = userName;
    passwordController.text = password;
    birthDateController.text = birthDate;
    weightController.text = weight.toString();
  }

  // 사용자 정보 업데이트
  void _updateUserInfo() {
    setState(() {
      userName = userNameController.text;
      password = passwordController.text; // 실제 앱에서는 비밀번호를 별도로 처리해야 함
      birthDate = birthDateController.text;
      weight = double.tryParse(weightController.text) ?? weight;
      isEditing = false; // 편집 모드 종료
    });
  }

  // 나이 계산 함수
  int _calculateAge(String birthDate) {
    final birthDateTime = DateTime.parse(birthDate);
    final currentDate = DateTime.now();
    final age = currentDate.year - birthDateTime.year;
    return (currentDate.month < birthDateTime.month ||
        (currentDate.month == birthDateTime.month &&
            currentDate.day < birthDateTime.day))
        ? age - 1
        : age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF141932),
        title: const Text(
          "사용자 정보",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 아이디
            Text(
              "아이디: $userId",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 프로필 이미지 (기본 아이콘 사용)
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 사용자 정보 표시
            _buildInfoRow("이름", userNameController, isEditing),
            const SizedBox(height: 10),
            _buildInfoRow("비밀번호", passwordController, isEditing), // 비밀번호는 편집할 수 없게 설정
            const SizedBox(height: 10),
            _buildInfoRow("생년월일 (나이)", TextEditingController(text: _calculateAge(birthDate).toString()), false), // 나이만 표시
            const SizedBox(height: 10),
            _buildInfoRow("몸무게 (kg)", weightController, isEditing),
            const SizedBox(height: 20),

            // 편집/저장 버튼
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (isEditing) {
                      _updateUserInfo();
                    } else {
                      isEditing = true; // 편집 모드로 전환
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF141932), // primary -> backgroundColor로 수정
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: Text(
                  isEditing ? "저장" : "편집",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 사용자 정보 한 줄
  Widget _buildInfoRow(String label, TextEditingController controller, bool isEditing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        isEditing
            ? SizedBox(
          width: 200,
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        )
            : Text(
          controller.text,
          style: TextStyle(fontSize: 16, color: Color(0x99000000)), // 수정된 부분
        ),
      ],
    );
  }

}
