import 'package:flutter/material.dart';
import 'package:somnus/screen/sleep_screen.dart';
import 'package:somnus/screen/sleep_weekly_screen.dart';
import 'user_info_page.dart'; // 사용자 정보 페이지 import
import 'promotion_page.dart'; // 프로모션 페이지 import
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart'; // package_info에서 package_info_plus로 수정
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // 사용자가 로그인할 때 ID를 저장하고 필요할 때 읽어오는 간단한 메커니즘을 제공



class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  // ===== 1. 클래스 변수 및 상태 관리 변수들 =====


  // 아코디언 상태 관리 (펼침 여부)
  Map<String, bool> _expandedSections = {
    "알림 설정": false,
    "서비스 정보": false,
    "프로모션": false,
    "기록 초기화": false,
  };

  // 알림 설정 상태
  Map<String, bool> _notificationSettings = {
    "푸시 알림": true,
    "야간 모드": false,
    "수면 분석 알림": true,
  };

  // 서비스 정보 섹션의 내용을 담은 Map 구조
  Map<String, bool> _serviceInfoExpandedItems = {
    "공지사항": false,
    // 다른 서비스 정보 항목들도 추가 가능
  };

  // 공지사항 목록 (실제로는 데이터베이스나 API에서 가져올 수 있음)
  List<Map<String, String>> _noticeList = [
    {"title": "앱 업데이트 안내 (v1.2.0)", "date": "2025-03-21"},
    {"title": "수면 분석 기능 개선", "date": "2025-03-10"},
    {"title": "새로운 기능 추가: 주간 수면 리포트", "date": "2025-03-05"},
    {"title": "시스템 점검 안내", "date": "2025-02-28"},
    {"title": "개인정보 처리방침 개정 안내", "date": "2025-02-20"},
    {"title": "음성 가이드 기능 추가", "date": "2025-02-15"},
  ];

  // 비밀번호 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController();

  // ===== 2. 최상위 build 메서드 =====
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
              // 사용자 정보 (별도 페이지로 이동)
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

              // 알림 설정 (펼치기/접기 기능)
              _buildExpandableTile("알림 설정", "알림 수신, 세부 설정"),
              _buildAnimatedExpandedContent(
                "알림 설정",
                ["푸시 알림", "야간 모드", "수면 분석 알림"],
                isNotificationSection: true,
              ),

              const SizedBox(height: 20),

              // 서비스 정보
              _buildExpandableTile("서비스 정보", "공지사항, 고객센터 문의"),
              _buildAnimatedExpandedContent("서비스 정보", [
                _buildServiceInfoItem("공지사항", "최신 앱 업데이트 및 서비스 변경 사항을 확인하세요."),
                _buildNoticeList(), // 공지사항 목록을 표시할 위젯
                _buildServiceInfoText("고객센터 문의: 앱 사용 중 문제가 발생한 경우, 고객센터로 문의하세요."),
                _buildContactButtons(), // 별도 메서드로 분리한 고객센터 문의 버튼
                _buildAppVersionInfo(), // 앱 버전 정보 컴포넌트
              ]),

              const SizedBox(height: 20),

              // 프로모션 (별도 페이지로 이동)
              _buildNavigationTile(
                title: "수면 제품",
                subtitle: "수면 제품 및 특별혜택",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PromotionPage()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 기록 초기화
              _buildExpandableTile("기록 초기화", "수면 기록 및 설정 데이터 초기화"),
              _buildAnimatedExpandedContent("기록 초기화", [
                _buildResetButton(), // 초기화 버튼 추가
                _buildServiceInfoText("주의: 데이터 초기화 후 복구가 불가능합니다."),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ===== 3. 기능 관련 메서드들 =====
// 사용자 ID를 가져오는 함수
  Future<String> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id') ?? 'smhrd'; // 기본값으로 'smhrd' 설정
  }

// 섹션 토글 메서드
  void _toggleSection(String section) {
    setState(() {
      _expandedSections[section] = !_expandedSections[section]!;
    });
  }

// 서비스 정보 항목 전환 함수
  void _toggleServiceInfoItem(String item) {
    setState(() {
      _serviceInfoExpandedItems[item] = !_serviceInfoExpandedItems[item]!;
    });
  }

// URL 실행을 위한 함수
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // URL을 실행할 수 없을 때 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('URL을 열 수 없습니다: $urlString')),
      );
    }
  }

// FastAPI를 사용한 비밀번호 검증 함수
  Future<bool> _validatePassword(String password) async {
    try {
      // 현재 로그인된 사용자 ID 가져오기
      final String currentUserId = await getCurrentUserId();

      // 제공된 FastAPI 서버 URL 사용
      final url = Uri.parse('http://192.168.219.211:8001/api/validate-password');

      // API 요청 보내기
      final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': currentUserId,
            'password': password
          })
      );

      // 응답 처리
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['valid'] == true; // API 응답에서 'valid' 필드가 true인지 확인
      } else {
        print('API 오류: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('비밀번호 검증 오류: $e');
      return false;
    }
  }

// 비밀번호 확인 대화상자 표시 함수
  void showPasswordConfirmDialog() {
    final _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('비밀번호 확인'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: '비밀번호를 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () async {
                // 비밀번호 확인을 위해 API 호출
                final isValid = await _validatePassword(_passwordController.text);
                if (isValid) {
                  Navigator.of(dialogContext).pop();
                  _resetData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("비밀번호가 일치하지 않습니다.")),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

// 초기화 확인 대화상자
  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("주의", style: TextStyle(color: Colors.red)),
          content: const Text("모든 수면 기록과 설정 데이터가 영구적으로 삭제됩니다. 이 작업은 취소할 수 없습니다. 계속하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                showPasswordConfirmDialog(); // 비밀번호 확인 대화상자 표시
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text("계속하기"),
            ),
          ],
        );
      },
    );
  }

// 비밀번호 입력 대화상자 (이전 버전 - 로컬 검증)
  void _showPasswordDialog() {
    _passwordController.clear();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("비밀번호 확인"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("초기화를 진행하려면 비밀번호를 입력하세요."),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "비밀번호",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                // 비밀번호 확인 로직
                if (_passwordController.text == "1234") { // 예시 비밀번호
                  Navigator.of(dialogContext).pop();
                  _resetData();
                } else {
                  // 비밀번호 오류 메시지
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("비밀번호가 일치하지 않습니다.")),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }

// 데이터 초기화 함수
  void _resetData() {
    // 여기에 실제 데이터 초기화 로직 구현
    // 예: SharedPreferences 초기화, 데이터베이스 초기화 등

    // 초기화 완료 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("모든 데이터가 초기화되었습니다."),
        backgroundColor: Colors.green,
      ),
    );

    // 필요하다면 상태 업데이트
    setState(() {
      // 초기화 후 상태 업데이트가 필요한 경우
    });
  }

// 사용자 ID 저장 함수 (로그인 성공 시 호출)
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', userId);
  }

  // ===== 4. UI 위젯 빌드 메서드들 =====

  // 4.1 네비게이션 방식으로 이동하는 설정 항목 (border 1.5)
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

  // 4.2 설정 항목 (탭하면 펼쳐짐)
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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

  // 4.3 부드러운 애니메이션으로 펼쳐지는 하위 설정 항목
  Widget _buildAnimatedExpandedContent(String section, List<dynamic> items, {bool isNotificationSection = false}) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: (_expandedSections[section] ?? false)
          ? Padding(
        padding: const EdgeInsets.only(left: 15, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map<Widget>((item) {
            if (item is String) {
              if (isNotificationSection) {
                return _buildNotificationItem(item);
              } else {
                return _buildServiceInfoText(item);
              }
            } else if (item is Widget) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: item,
              );
            }
            return const SizedBox.shrink(); // 기본값 리턴
          }).toList(),
        ),
      )
          : const SizedBox.shrink(),
    );
  }

  // 4.4 알림 설정 항목을 위한 위젯
  Widget _buildNotificationItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active,
                color: Colors.black,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          Switch(
            value: _notificationSettings[title] ?? false,
            onChanged: (value) {
              setState(() {
                _notificationSettings[title] = value;
                // 여기에 실제 알림 설정을 저장하는 로직 추가 가능
              });
            },
            activeColor: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  // 4.5 서비스 정보 텍스트를 위한 위젯
  Widget _buildServiceInfoText(String text) {
    // 텍스트에 ":"이 포함되어 있으면 분리
    if (text.contains(":")) {
      List<String> parts = text.split(":");
      String title = parts[0].trim();
      String description = parts.length > 1 ? parts[1].trim() : "";

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.blueAccent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$title:",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.7),
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // 기존 형식 유지
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.blueAccent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
                softWrap: true,
              ),
            ),
          ],
        ),
      );
    }
  }

  // 4.6 서비스 정보 내의 공지사항 항목을 생성하는 위젯
  Widget _buildServiceInfoItem(String title, String description) {
    return GestureDetector(
      onTap: () => _toggleServiceInfoItem(title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.announcement_outlined,
              color: Colors.blueAccent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$title:",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.7),
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
            Icon(
              _serviceInfoExpandedItems[title] ?? false
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }

  // 4.7 공지사항 목록을 표시하는 위젯
  Widget _buildNoticeList() {
    return (_serviceInfoExpandedItems["공지사항"] ?? false)
        ? Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: _noticeList.map((notice) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 8,
                  color: Colors.black,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice["title"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      Text(
                        notice["date"]!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    )
        : const SizedBox.shrink();
  }

  // 4.8 고객센터 문의 버튼 (가로 배치)
  Widget _buildContactButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _launchURL('mailto:support@yourapp.com'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("이메일로 문의"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _launchURL('tel:+123456789'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("전화로 문의"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 4.9 앱 버전 정보 위젯
  Widget _buildAppVersionInfo() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final packageInfo = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.blueAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "앱 버전: ${packageInfo.version} (빌드: ${packageInfo.buildNumber})",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const SizedBox(width: 30),
                      Text(
                        "패키지명: ${packageInfo.packageName}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const Text("앱 버전 정보를 가져올 수 없습니다.");
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }

  // 4.10 초기화 버튼 위젯
  Widget _buildResetButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: _showResetConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_forever, size: 20),
            SizedBox(width: 8),
            Text(
              "기록 초기화 실행",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}