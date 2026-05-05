
// ==============================================
// FEATURE CARDS GRID
// ==============================================
import 'package:edupro/presentation/home/controllers/home.controller.dart';
import 'package:edupro/presentation/utill_widget/feature_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeatureCardsGrid extends StatelessWidget {
  const FeatureCardsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.00, // Changed from 0.95 to give more height
      ),
      itemCount: controller.featureCards.length,
      itemBuilder: (context, i) => FeatureCard(
        card: controller.featureCards[i],
        onTap: () => controller.onCardTap(controller.featureCards[i].title),
      ),
    );
  }
}