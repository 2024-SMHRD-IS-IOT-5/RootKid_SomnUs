import 'package:flutter/material.dart';
import 'package:somnus/screen/home_page.dart';
import 'package:somnus/screen/report_page.dart';
import 'package:somnus/screen/chat_page.dart';
import 'package:somnus/screen/sleepmusic.dart';
import 'package:somnus/screen/settings_page.dart'; // ✅ 설정 페이지 import

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ReportPage(),
    const ChatPage(),
    const SleepMusicScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF141932),
        title: const Text(
          "SomnUs",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // ✅ 설정 페이지로 이동 (네비게이션 바 없이)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF141932),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "홈"),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined),
            label: "보고서",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_outlined),
            label: "채팅",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.headphones), label: "노래"),
        ],
      ),
    );
  }
}
