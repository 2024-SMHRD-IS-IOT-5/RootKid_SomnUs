import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:somnus/screen/login_page.dart';
import 'package:somnus/services/auth_service.dart';
import 'package:somnus/services/websocket_service.dart';

class StudentInfoPage extends StatefulWidget {
  final String id;
  final String password;
  final String name;

  // ✅ `id`, `password`, `name`을 받을 생성자 추가
  const StudentInfoPage({
    Key? key,
    required this.id,
    required this.password,
    required this.name,
  }) : super(key: key);

  @override
  _StudentInfoPageState createState() => _StudentInfoPageState();
}

class _StudentInfoPageState extends State<StudentInfoPage> {
  final AuthService _authService = AuthService();
  final WebSocketService _webSocketService = WebSocketService();

  DateTime _selectedDate = DateTime.now();
  int _selectedWeight = 50;

  // ✅ 생년월일 선택 (CupertinoDatePicker)
  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "완료",
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  minimumDate: DateTime(1950, 1, 1),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ 몸무게 선택 (CupertinoPicker)
  void _showWeightPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "완료",
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectedWeight - 30,
                  ),
                  itemExtent: 40.0,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedWeight = index + 30;
                    });
                  },
                  children: List.generate(121, (index) {
                    return Center(
                      child: Text(
                        "${index + 30} kg",
                        style: const TextStyle(fontSize: 22),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ FastAPI 서버에 회원가입 요청
  void _registerStudent() async {
    int age = DateTime.now().year - _selectedDate.year;

    bool isRegistered = await _authService.registerStudent(
      widget.id,
      widget.password,
      widget.name,
      age,
      _selectedWeight,
    );

    if (isRegistered) {
      Fluttertoast.showToast(msg: "회원가입 성공!", gravity: ToastGravity.BOTTOM);

      // ✅ WebSocket 연결
      _webSocketService.connect(widget.id);

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
            const SizedBox(height: 30),

            // 안내 문구
            const Text(
              '더 정확한 수면 분석을 위해 최소한의 정보를 입력해주세요. 입력하신 정보는 개인 맞춤형 피드백 제공을 위해 사용됩니다.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // 생년월일 선택 필드
            const Text('생년월일', style: _labelStyle),
            _buildDatePicker(),

            const SizedBox(height: 20),

            // 몸무게 선택 필드
            const Text('몸무게 (kg)', style: _labelStyle),
            _buildWeightPicker(),

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
                onPressed: _registerStudent, // ✅ 서버 요청 실행
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

  // 생년월일 선택 버튼
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: _buildSelectableContainer(
        "${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일",
      ),
    );
  }

  // 몸무게 선택 버튼
  Widget _buildWeightPicker() {
    return GestureDetector(
      onTap: () => _showWeightPicker(context),
      child: _buildSelectableContainer("$_selectedWeight kg"),
    );
  }

  // **📌 공통 선택 가능한 컨테이너 UI**
  Widget _buildSelectableContainer(String text) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(color: Colors.black, fontSize: 16)),
          const Icon(Icons.arrow_drop_down, color: Colors.black),
        ],
      ),
    );
  }
}
