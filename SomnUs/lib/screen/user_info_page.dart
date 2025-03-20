import 'package:flutter/material.dart';
import 'package:somnus/services/auth_service.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final AuthService _authService = AuthService();

  // 사용자 정보
  String userId = "";
  String userName = "";
  String password = "";
  int age = 0;
  double weight = 0.0;
  bool isLoading = true;
  String errorMessage = "";

  // 텍스트 필드 상태
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  bool isEditing = false;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final userInfo = await _authService.getUserInfo();

      setState(() {
        userId = userInfo["id"] ?? "";
        userName = userInfo["name"] ?? "";
        // password는 보안상 표시하지 않음
        password = "••••••••";
        age = userInfo["age"] ?? 0;


        weight = (userInfo["weight"] is int)
            ? (userInfo["weight"] as int).toDouble()
            : (userInfo["weight"] as num?)?.toDouble() ?? 0.0;

        // 컨트롤러 초기화
        userNameController.text = userName;
        passwordController.text = ""; // 비밀번호는 빈 값으로
        weightController.text = weight.toString();

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "사용자 정보를 가져오는데 실패했습니다: ${e.toString()}";
        isLoading = false;
      });
    }
  }


  Future<void> _updateUserInfo() async {
    setState(() {
      isUpdating = true;
    });

    try {
      final updatedInfo = {
        "name": userNameController.text,
        "weight": double.tryParse(weightController.text) ?? weight,
        // 비밀번호 변경 시에만 포함
        if (passwordController.text.isNotEmpty && passwordController.text != "••••••••")
          "password": passwordController.text,
      };

      final success = await _authService.updateUserInfo(updatedInfo);

      if (success) {
        setState(() {
          userName = userNameController.text;
          // 비밀번호가 변경되었다면 마스킹 처리
          if (passwordController.text.isNotEmpty && passwordController.text != "••••••••") {
            password = "••••••••";
          }
          weight = double.tryParse(weightController.text) ?? weight;
          isEditing = false;
          isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("정보가 성공적으로 업데이트되었습니다")),
        );
      } else {
        setState(() {
          isUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("정보 업데이트에 실패했습니다")),
        );
      }
    } catch (e) {
      setState(() {
        isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류가 발생했습니다: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF141932),
        title: const Text(
          "사용자 정보",
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
            : Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              // 프로필 이미지
              Center(
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.grey,  // 프로필 이미지 배경색
                  child: const Icon(
                    Icons.person,
                    size: 130,  // 아이콘 크기
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),  // 프로필 이미지와 첫 번째 텍스트 사이의 간격

              // 사용자 아이디
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "아이디",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$userId",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 사용자 정보 (이름, 비밀번호, 생년월일, 몸무게 등)
              _buildInfoRow("이름", userNameController, isEditing),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "비밀번호",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  isEditing
                      ? SizedBox(
                    width: 200,
                    child: TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        hintText: "새 비밀번호 입력",
                      ),
                      obscureText: true, // 비밀번호 숨김 처리
                    ),
                  )
                      : const Text(
                    "••••••••",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "나이",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$age세",
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoRow("몸무게 (kg)", weightController, isEditing),
              const SizedBox(height: 20),

              // 편집/저장 버튼
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8, // 화면 가로 크기의 80%
                  child: ElevatedButton(
                    onPressed: isUpdating
                        ? null // 업데이트 중에는 버튼 비활성화
                        : () {
                      setState(() {
                        if (isEditing) {
                          _updateUserInfo(); // 서버에 업데이트 요청
                        } else {
                          isEditing = true; // 편집 모드로 전환
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // 깔끔한 색상으로 변경
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // 둥근 모서리
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      elevation: 3, // 적당한 그림자 효과
                    ),
                    child: isUpdating
                        ? const SizedBox(
                      width: 60,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      isEditing ? "저장" : "편집",
                      style: const TextStyle(
                          fontSize: 18),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

// 사용자 정보 텍스트 필드 렌더링 (이름, 몸무게 등)
  Widget _buildInfoRow(String label, TextEditingController controller, bool isEditing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        isEditing
            ? SizedBox(
          width: 200,
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.black), // 텍스트 색상을 검정색으로 설정
            decoration: InputDecoration(
              hintText: label, // 힌트 텍스트로 라벨 추가
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)), // 네모난 테두리로 둥글게 처리
              ),
              filled: true, // 배경 색을 흰색으로 설정
              fillColor: Colors.white, // 배경 색을 흰색으로 설정
            ),
          ),
        )
            : Text(
          controller.text,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }
}