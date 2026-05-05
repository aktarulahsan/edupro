
// Navigation Chip
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:edupro/presentation/home/controllers/home.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int navIndex;

  const NavChip({
    super.key,
    required this.icon,
    required this.label,
    required this.navIndex,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() => GestureDetector(
      onTap: () => controller.setActiveNav(navIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: controller.activeNavIndex.value == navIndex
              ? kPrimary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: controller.activeNavIndex.value == navIndex
                  ? Colors.white
                  : kTextGrey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: controller.activeNavIndex.value == navIndex
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: controller.activeNavIndex.value == navIndex
                    ? Colors.white
                    : kTextGrey,
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
