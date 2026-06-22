// User Profile Chip
import 'package:edupro/infrastructure/navigation/routes.dart';
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileChip extends StatelessWidget {
  final String userName;
  final String userInitials;
  final int userXP;

  const UserProfileChip({
    super.key,
    required this.userName,
    required this.userInitials,
    required this.userXP,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kPrimaryLight,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: kPrimary,
            child: Text(
              userInitials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => Get.toNamed(Routes.SETTING),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: kTextDark,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 13,
                      color: kPrimary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$userXP Score',
                      style: const TextStyle(
                        fontSize: 11,
                        color: kPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
