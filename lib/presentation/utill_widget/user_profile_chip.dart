// User Profile Chip
import 'package:edupro/infrastructure/navigation/routes.dart';
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileChip extends StatelessWidget {
  final String userName;
  final String userInitials;
  final int userXP;
  final bool isScoreLoading;
  final String scoreErrorMessage;

  const UserProfileChip({
    super.key,
    required this.userName,
    required this.userInitials,
    required this.userXP,
    required this.isScoreLoading,
    required this.scoreErrorMessage,
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
                _buildScoreStatus(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreStatus() {
    if (isScoreLoading) {
      return const Row(
        children: [
          SizedBox(
            width: 11,
            height: 11,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: kPrimary),
          ),
          SizedBox(width: 5),
          Text(
            'Loading score',
            style: TextStyle(
              fontSize: 11,
              color: kPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final hasError = scoreErrorMessage.isNotEmpty;
    return Row(
      children: [
        Icon(
          hasError ? Icons.error_outline_rounded : Icons.emoji_events_rounded,
          size: 13,
          color: hasError ? AppColors.error : kPrimary,
        ),
        const SizedBox(width: 3),
        Text(
          hasError ? scoreErrorMessage : '$userXP Score',
          style: TextStyle(
            fontSize: 11,
            color: hasError ? AppColors.error : kPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
