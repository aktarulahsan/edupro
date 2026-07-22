// Logo Section
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LogoSection extends StatelessWidget {
  const LogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(1),

          child: Image.asset(
            'assets/images/logo.png',
            width: 36,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 4),
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
              style: TextStyle(color: kTextGrey, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}
