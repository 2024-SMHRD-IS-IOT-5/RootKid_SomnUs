import 'package:flutter/material.dart';

class PromotionPage extends StatelessWidget {
  const PromotionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF141932),
        title: const Text(
          '수면 제품',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPromotionCard(
              '프리미엄 메모리폼 매트리스',
              '편안한 숙면을 위한 고급 메모리폼 매트리스!',
              '매트리스 15% 할인',
              'images/mattress.png',
            ),
            _buildPromotionCard(
              '천연 실크 수면 안대',
              '부드러운 실크로 제작된 프리미엄 안대.',
              '사은품 증정',
              'images/sleep_mask.png',
            ),
            _buildPromotionCard(
              '알러지 방지 기능성 이불',
              '알러지 걱정 없는 깨끗한 소재.',
              '20% 할인 적용',
              'images/blanket.png',
            ),
            _buildPromotionCard(
              '스마트 수면 베개',
              '개인 맞춤형 스마트 베개로 숙면 유도.',
              '무료 배송 이벤트',
              'images/pillow.png',
            ),
            _buildPromotionCard(
              '아로마테라피 디퓨저',
              '숙면을 위한 아로마 향기 디퓨저.',
              '전 제품 10% 할인',
              'images/diffuser.png',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCard(
      String title,
      String description,
      String benefit,
      String imageAsset,
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      // GestureDetector나 InkWell이 필요 없다면 제거
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 이미지 영역
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.asset(
              imageAsset,
              // 가로 폭에 맞춰서 꽉 채우고, 세로 높이는 고정값(또는 원하는 높이)으로 설정
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          // 텍스트 영역
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF141932),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0x99000000),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  benefit,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
