
// ==============================================
// PRIMARY NAVIGATION BAR
// ==============================================
import 'package:edupro/infrastructure/dal/model/nav_item.dart';
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:edupro/presentation/utill_widget/nav_chip.dart';
import 'package:flutter/material.dart';

class PrimaryNavBar extends StatelessWidget {
  const PrimaryNavBar({super.key});

  final List<NavItem> topNav = const [
    NavItem(Icons.home_rounded, 'Home'),
    NavItem(Icons.help_outline_rounded, 'MCQ'),
    NavItem(Icons.account_balance_outlined, 'BCS'),
    NavItem(Icons.shuffle_rounded, 'Random'),
    NavItem(Icons.assignment_outlined, 'Mock Exam'),
    NavItem(Icons.menu_book_outlined, 'Subjective'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCardBg,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: List.generate(topNav.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: NavChip(
                icon: topNav[index].icon,
                label: topNav[index].label,
                navIndex: index,
              ),
            );
          }),
        ),
      ),
    );
  }
}

