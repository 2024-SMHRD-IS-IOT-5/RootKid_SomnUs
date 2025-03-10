import 'package:flutter/material.dart';

class SleepMusicScreen extends StatefulWidget {

  const SleepMusicScreen({super.key});

  @override
  _SleepMusicScreenState createState() => _SleepMusicScreenState();
}

class _SleepMusicScreenState extends State<SleepMusicScreen> {
  List<Map<String, String>> sleepMusicList = [
    {"title": "잔잔한 피아노", "image": "images/piano.jpg"},
    {"title": "자연 소리", "image": "images/nature.jpg"},
    {"title": "화이트 노이즈", "image": "images/night.jpg"},
    {"title": "빗소리", "image": "images/rain.jpg"},
    {"title": "고래소리", "image": "images/dolphin.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "수면 음악 플레이리스트🎵",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: sleepMusicList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            child: SizedBox(
              height: 70,
              child: Card(
                elevation: 4, // 그림자 효과
                shadowColor: Colors.black.withOpacity(0.7), // 부드러운 그림자
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // 카드 둥글게
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      sleepMusicList[index]["image"]!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    sleepMusicList[index]["title"]!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.play_circle_outline, size: 30, color: Color(0xFF141932),),
                    onPressed: () {
                      // 음악 재생 로직
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
