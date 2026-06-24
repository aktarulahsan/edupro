import 'package:edupro/infrastructure/dal/model/scoreboard_model.dart';
import 'package:edupro/infrastructure/navigation/routes.dart';
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:edupro/presentation/home/controllers/home.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomePerformanceSection extends GetView<HomeController> {
  const HomePerformanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.dashboardData.value;

      if (controller.isScoreLoading.value && data == null) {
        return const _LoadingCard();
      }

      if (data == null) {
        return _ErrorCard(onRetry: controller.loadUserTotalScore);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Your Progress',
            actionLabel: 'View details',
            onAction: () => Get.toNamed(Routes.SCOREBOARD),
          ),
          const SizedBox(height: 0),
          _ProgressCard(data: data),
          const SizedBox(height: 5),
          const _SectionHeader(title: 'Recent Activity'),
          const SizedBox(height: 10),
          _RecentActivityCard(submission: data.latestSubmission),
        ],
      );
    });
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({this.title = '', this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final DashboardData data;

  const _ProgressCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final accuracy = data.averagePercentage.clamp(0, 100).toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppColors.blueToSlateGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall accuracy',
                      style: TextStyle(
                        color: AppColors.textWhite70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${accuracy.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textWhite.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: AppColors.xpGold,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${data.totalScore} points',
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: accuracy / 100,
              minHeight: 5,
              backgroundColor: AppColors.textWhite.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation(AppColors.xpGold),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Metric(
                icon: Icons.assignment_turned_in_outlined,
                value: '${data.totalSubmissions}',
                label: 'Attempts',
              ),
              _Metric(
                icon: Icons.check_circle_outline_rounded,
                value: '${data.correctAnswers}',
                label: 'Correct',
              ),
              _Metric(
                icon: Icons.workspace_premium_outlined,
                value: '${data.passedCount}',
                label: 'Passed',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Metric({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.textWhite70, size: 16),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textWhite70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final Submission? submission;

  const _RecentActivityCard({required this.submission});

  @override
  Widget build(BuildContext context) {
    final item = submission;
    if (item == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration,
        child: const Row(
          children: [
            Icon(Icons.history_rounded, color: AppColors.textTertiary),
            SizedBox(width: 12),
            Text(
              'No activity yet. Start your first practice.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.SCOREBOARD),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration,
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question Set ${item.setNo}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.totalAns ?? 0} answered  •  ${_formatDate(item.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(String value) {
    try {
      return DateFormat('dd MMM, yyyy').format(DateTime.parse(value).toLocal());
    } catch (_) {
      return 'Recently';
    }
  }

  static final BoxDecoration _cardDecoration = BoxDecoration(
    color: AppColors.backgroundWhite,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AppColors.border),
    boxShadow: const [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorCard({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.errorLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.errorLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.error),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Could not load your progress.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
