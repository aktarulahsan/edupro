
// Logo Section
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LogoSection extends StatelessWidget {
  const LogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: kPrimary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.psychology_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EduPro',
              style: TextStyle(
                color: kPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Learn • Practice • Master',
              style: TextStyle(
                color: kTextGrey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

