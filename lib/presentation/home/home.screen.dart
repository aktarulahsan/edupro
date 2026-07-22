// home.screen.dart
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:edupro/presentation/home/banner_slider.dart';
import 'package:edupro/presentation/home/home_bottom_navigation_bar.dart';
import 'package:edupro/presentation/home/home_performance_section.dart';
import 'package:edupro/presentation/utill_widget/feature_cards_grid.dart';
import 'package:edupro/presentation/utill_widget/logo_section.dart';
import 'package:edupro/presentation/utill_widget/user_profile_chip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/home.controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }

    return Scaffold(
      backgroundColor: kBackground,
      bottomNavigationBar: const HomeBottomNavigationBar(),
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(),
            const Divider(height: 1, color: kDivider),

            BannerSlider(),

            const Divider(height: 1, color: kDivider),
            Expanded(
              child: const SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 1,
                  bottom: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomePerformanceSection(),
                    // SizedBox(height: 10),
                    Text(
                      'Explore Practice',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10),
                    FeatureCardsGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================
// TOP BAR WIDGET
// ==============================================
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Container(
      color: kCardBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const LogoSection(),
          const Spacer(),
          Obx(
            () => UserProfileChip(
              userName: controller.userName.value,
              userInitials: controller.userInitials.value,
              userXP: controller.userXP.value,
              isScoreLoading: controller.isScoreLoading.value,
              scoreErrorMessage: controller.scoreErrorMessage.value,
            ),
          ),
        ],
      ),
    );
  }
}
