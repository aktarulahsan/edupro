
// ==============================================
// SECTION HEADER
// ==============================================
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: kPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.grid_view_rounded, color: kTextDark, size: 20),
        const SizedBox(width: 8),
        const Text(
          'Smart Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: kTextDark,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
