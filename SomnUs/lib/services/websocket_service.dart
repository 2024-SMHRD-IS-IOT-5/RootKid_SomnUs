import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String socketUrl = "ws://192.168.219.211:8001/ws";
  WebSocketChannel? _channel;

  void connect(String token) {
    _channel = WebSocketChannel.connect(Uri.parse("$socketUrl?token=$token"));
    print("WebSocket 연결 성공!");

    _channel!.stream.listen((message) {
      print("서버 메시지: $message");
    });
  }

  void sendMessage(String message) {
    _channel?.sink.add(message);
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
