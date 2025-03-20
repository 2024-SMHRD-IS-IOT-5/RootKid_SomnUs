import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:somnus/services/auth_service.dart';
import 'package:somnus/config/config.dart';

class NfcWebSocketService {
  late final IOWebSocketChannel channel;

  NfcWebSocketService() {
    // 토큰을 가져와서 헤더에 추가
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

  /// WebSocket 메시지를 자동으로 수신하여 NFC 상태가 변경되면 알림을 띄움.
  void listenForNfc(BuildContext context) {
    bool? lastState; // 이전 상태 저장

    channel.stream.listen((message) {
      print("WebSocket received: $message");
      try {
        final data = jsonDecode(message);
        bool nfcState = data['nfc_state'];
        print("수신된 nfcState: $nfcState");

        // 이전 상태와 현재 상태를 비교하여 변화 감지
        if (lastState == null || lastState != nfcState) {
          if (nfcState == true) {
            _showNfcAlert(context, "핸드폰을 거치하였습니다.");
          } else {
            _showNfcAlert(context, "핸드폰이 거치대에서 제거되었습니다.");
          }
          lastState = nfcState; // 상태 업데이트
        }
      } catch (e) {
        print("메시지 처리 오류: $e");
      }
    }, onError: (error) {
      print("WebSocket 에러: $error");
    }, onDone: () {
      print("WebSocket 연결 종료");
    });
  }

  void _showNfcAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("알림"),
        content: Text(message), // 동적으로 메시지 변경
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
