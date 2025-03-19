import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // ✅ 스크롤 컨트롤러 추가
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.219.211:8001/ws'), // ✅ WebSocket 서버 주소
  );

  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _channel.stream.listen((message) {
      try {
        final data = jsonDecode(message);
        final chatMessage = ChatMessage(
          text: data['text'] as String,
          sender: data['sender'] as String,
        );

        setState(() {
          messages.add(chatMessage);
          _scrollToBottom(); // ✅ 새 메시지가 오면 자동 스크롤
        });
      } catch (e) {
        print("JSON 파싱 에러: $e");
      }
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final messageText = _controller.text;
      setState(() {
        messages.add(ChatMessage(text: messageText, sender: "client"));
        _scrollToBottom(); // ✅ 새 메시지 입력 후 자동 스크롤
      });
      _channel.sink.add(messageText);
      _controller.clear();
    }
  }

  // ✅ 메시지가 추가될 때 자동 스크롤
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50), // AppBar 높이 지정
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white, // ✅ 기존 AppBar 배경색 유지
            boxShadow: [
              BoxShadow(
                color: Colors.black26, // ✅ 그림자 색상 (연한 검정)
                blurRadius: 5, // ✅ 그림자 퍼짐 정도
                offset: Offset(0, 3), // ✅ 아래쪽으로 그림자 이동
              ),
            ],
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 1.5), // ✅ 하단 테두리 추가
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.white, // ✅ AppBar 배경색 유지
            elevation: 0, // ✅ 기본 그림자 제거 (커스텀 그림자만 사용)
            title: const Text(
              "SomnUs와의 채팅",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ✅ 채팅 메시지 리스트 (자동 스크롤 적용)
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // ✅ 스크롤 컨트롤러 연결
              padding: const EdgeInsets.only(top : 10, bottom: 5),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isChatbot = msg.sender == "chatbot";

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        isChatbot
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                    children: [
                      if (isChatbot) ...[
                        // ✅ 챗봇 프로필 아이콘
                        const CircleAvatar(
                          backgroundColor: Color(0xFF141932),
                          child: Icon(Icons.smart_toy, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        // ✅ 긴 메시지가 자동 줄바꿈되도록 설정
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width *
                                0.6, // ✅ 메시지 박스 최대 너비 설정
                          ),
                          decoration: BoxDecoration(
                            color: isChatbot ? Color(0xFF141932) : Colors.black12,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              fontSize: 16,
                              color: isChatbot ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      if (!isChatbot) ...[
                        const SizedBox(width: 10),
                        // ✅ 사용자 프로필 아이콘
                        const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // ✅ 메시지 입력창 & 전송 버튼
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40, // ✅ 입력창 높이 줄이기
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "메시지를 입력하세요...",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        // ✅ 내부 여백 조절
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                            width: 2.0,
                          ), // ✅ 테두리 색상 변경
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ), // ✅ 포커스 시 테두리 색상 변경
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.grey),
                  iconSize: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ 메시지 데이터 모델
class ChatMessage {
  final String sender; // "chatbot" 또는 "client"
  final String text;

  ChatMessage({required this.text, required this.sender});
}
