import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:somnus/screen/start_page.dart';
import 'package:somnus/screen/sleep_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Flutter 엔진 초기화 (SharedPreferences 오류 방지)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        locale: Locale('ko', 'KR'),
        //한국어 설정
        supportedLocales: [
          Locale('en', 'US'),
          Locale('ko', 'KR'),
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          fontFamily: "NotoSansKR",
        ),
        home: SplashScreen()
    );
  }
}


