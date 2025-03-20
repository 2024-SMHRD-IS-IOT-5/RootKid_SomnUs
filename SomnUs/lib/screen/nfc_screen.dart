import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:somnus/services/auth_service.dart';
import 'package:somnus/config/config.dart';

class NfcWebSocketService {
  late final IOWebSocketChannel channel;

  NfcWebSocketService() {
    // 토큰을 가져와서 헤더에 추가합니다.
    String? token = AuthService().getToken();
    if (token == null) {
      throw Exception("로그인 토큰이 없습니다.");
    }
    channel = IOWebSocketChannel.connect(
      Uri.parse('${Web.webUrl}/nfc'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// WebSocket 메시지를 자동으로 수신하여 NFC 상태가 true이고, 부모 계정이면 알림을 띄웁니다.
  void listenForNfc(BuildContext context) {
    channel.stream.listen((message) {
      print("WebSocket received: $message");
      try {
        final data = jsonDecode(message);
        bool nfcState = data['nfc_state'];
        print("수신된 nfcState: $nfcState");

        //if (nfcState == true && AuthService().isParent()) {
        if (nfcState == true ) {
          print("if문 들어왔다.");
          _showNfcAlert(context);
        }
        else {print("if문 안들어갔다");}
      } catch (e) {
        print("메시지 처리 오류: $e");
      }
    }, onError: (error) {
      print("WebSocket 에러: $error");
    }, onDone: () {
      print("WebSocket 연결 종료");
    });
  }

  void _showNfcAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("알림"),
        content: const Text("핸드폰을 거치하였습니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  void dispose() {
    channel.sink.close();
  }
}
