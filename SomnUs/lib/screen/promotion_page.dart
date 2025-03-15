import 'package:flutter/material.dart';

class PromotionPage extends StatelessWidget {
  const PromotionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF141932),
        title: const Text(
          '프로모션',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 프로모션 1: 제품 추천 및 할인 쿠폰 제공
          _buildPromotionCard(
            context,
            '수면 개선 제품 추천 + 할인 쿠폰',
            '수면 제품을 추천하고, 할인 쿠폰을 제공하여 수면의 질을 향상시키세요!',
            '추천 제품과 함께 10% 할인 쿠폰 제공',
          ),

          // 프로모션2: 수면 목표 달성 시 기프트카드 제공
          _buildPromotionCard(
            context,
            '수면 목표 달성 기프트카드 제공',
            '"목표 수면 시간을 달성하면 기프트카드를 증정합니다! 정해진 수면 시간을 꾸준히 유지하세요.!',
            '수면 목표 달성 시 기프트카드 증정',
          ),

          // 프로모션 3: 제품 리뷰 + 소셜 미디어 캠페인
          _buildPromotionCard(
            context,
            '제품 리뷰 + 소셜 미디어 참여',
            '수면 제품을 사용하고 SNS에 후기를 올리면 경품을 받을 수 있어요!',
            '후기 작성 시 추첨을 통해 경품 제공',
          ),

          // 프로모션 4: 수면 관련 콘텐츠 제공 + 제품 홍보
          _buildPromotionCard(
            context,
            '수면 관련 콘텐츠 제공',
            '수면 개선 팁과 추천 제품을 콘텐츠와 함께 제공해요!',
            '수면 개선 콘텐츠 내 제품 추천',
          ),

          // 프로모션 5: 무료 수면 분석과 추천 제품 연계
          _buildPromotionCard(
            context,
            '수면 분석 + 추천 제품 연계',
            '수면 분석 후 맞춤형 제품을 추천받고 할인 혜택을 받아보세요!',
            '수면 분석 후 할인 혜택 제공',
          ),
        ],
      ),
    );
  }

  // 프로모션 카드 위젯
  Widget _buildPromotionCard(BuildContext context, String title, String description, String benefit) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
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
              style: const TextStyle(fontSize: 16, color: Color(0x99000000)),
            ),
            const SizedBox(height: 12),
            Text(
              benefit,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
