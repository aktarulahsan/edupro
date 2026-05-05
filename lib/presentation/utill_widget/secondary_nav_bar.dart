
// ==============================================
// SECONDARY NAVIGATION BAR
// ==============================================
import 'package:edupro/infrastructure/dal/model/nav_item.dart';
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:edupro/presentation/utill_widget/nav_chip.dart';
import 'package:flutter/material.dart';

class SecondaryNavBar extends StatelessWidget {
  const SecondaryNavBar({super.key});

  final List<NavItem> secondNav = const [
    NavItem(Icons.bar_chart_rounded, 'Scoreboard'),
    NavItem(Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCardBg,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: List.generate(secondNav.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: NavChip(
                icon: secondNav[index].icon,
                label: secondNav[index].label,
                navIndex: index + 6, // Offset for secondary nav
              ),
            );
          }),
        ),
      ),
    );
  }
}