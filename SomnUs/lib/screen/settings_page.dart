import 'package:flutter/material.dart';
import 'package:somnus/model/sleep_daily_data.dart';
import 'package:somnus/model/sleep_weekly_data.dart';
import 'package:somnus/screen/promotion_page.dart';
import 'user_info_page.dart'; // 사용자 정보 페이지 import

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  // ✅ 아코디언 상태 관리 (펼침 여부)
  Map<String, bool> _expandedSections = {
    "알림 설정": false,
    "서비스 정보": false,
    "프로모션": false,
    "기록 초기화": false,
  };

  void _toggleSection(String section) {
    setState(() {
      _expandedSections[section] = !_expandedSections[section]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF141932),
        title: const Text(
          "마이페이지",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ 사용자 정보 (별도 페이지로 이동)
              _buildNavigationTile(
                title: "사용자 정보",
                subtitle: "프로필, 로그아웃",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserInfoPage()),
                  );
                },
              ),
              const SizedBox(height: 20),

              // ✅ 알림 설정 (펼치기/접기 기능)
              _buildExpandableTile("알림 설정", "알림 수신, 세부 설정"),
              _buildAnimatedExpandedContent("알림 설정", ["푸시 알림", "야간 모드", "수면 분석 알림"]),

              const SizedBox(height: 20),

              // ✅ 서비스 정보
              _buildExpandableTile("서비스 정보", "공지사항, 고객센터 문의"),
              _buildAnimatedExpandedContent("서비스 정보", ["공지사항", "고객센터 문의", "앱 버전 정보"]),

              const SizedBox(height: 20),

              // ✅ 프로모션 (별도 페이지로 이동)
              _buildNavigationTile(
                title: "프로모션",
                subtitle: "이벤트 및 특별 혜택",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PromotionPage()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ✅ 기록 초기화
              _buildExpandableTile("기록 초기화", "수면 기록 및 설정 데이터 초기화"),
              _buildAnimatedExpandedContent("기록 초기화", ["기록 초기화 실행", "데이터 초기화 후 복구 불가"]),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// **📌 설정 항목 (탭하면 펼쳐짐)**
  Widget _buildExpandableTile(String title, String subtitle) {
    return GestureDetector(
      onTap: () => _toggleSection(title),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            Icon(
              _expandedSections[title] ?? false ? Icons.expand_less : Icons.expand_more,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  /// **📌 부드러운 애니메이션으로 펼쳐지는 하위 설정 항목**
  Widget _buildAnimatedExpandedContent(String section, List<String> items) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: (_expandedSections[section] ?? false)
          ? Padding(
        padding: const EdgeInsets.only(left: 15, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(item, style: const TextStyle(fontSize: 16)),
                ],
              ),
            );
          }).toList(),
        ),
      )
          : const SizedBox.shrink(),
    );
  }

  /// **📌 네비게이션 방식으로 이동하는 설정 항목 (border 1.5)**
  Widget _buildNavigationTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 20),
          ],
        ),
      ),
    );
  }
}
