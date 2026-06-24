import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:edupro/presentation/home/controllers/home.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeBottomNavigationBar extends GetView<HomeController> {
  const HomeBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              height: 68,
              elevation: 0,
              backgroundColor: AppColors.backgroundWhite,
              indicatorColor: AppColors.primaryBackground,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return IconThemeData(
                  color: selected ? AppColors.primary : AppColors.textTertiary,
                  size: selected ? 25 : 23,
                );
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return TextStyle(
                  color: selected
                      ? AppColors.primaryDark
                      : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                );
              }),
            ),
          ),
          child: Obx(
            () => NavigationBar(
              selectedIndex: controller.activeNavIndex.value,
              onDestinationSelected: controller.setActiveNav,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                  tooltip: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.quiz_outlined),
                  selectedIcon: Icon(Icons.quiz_rounded),
                  label: 'Practice',
                  tooltip: 'MCQ Practice',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment_rounded),
                  label: 'Mock',
                  tooltip: 'Mock Exam',
                ),
                NavigationDestination(
                  icon: Icon(Icons.leaderboard_outlined),
                  selectedIcon: Icon(Icons.leaderboard_rounded),
                  label: 'Scores',
                  tooltip: 'Scoreboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                  tooltip: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
