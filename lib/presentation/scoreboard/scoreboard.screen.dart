import 'package:edupro/infrastructure/dal/model/scoreboard_model.dart';
import 'package:edupro/infrastructure/dal/model/leaderboard_model.dart';
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:edupro/presentation/scoreboard/controllers/scoreboard.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScoreboardScreen extends GetView<ScoreboardController> {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      bottomNavigationBar: Obx(() {
        if (controller.activeTab.value == 1 &&
            controller.leaderboardData.value != null &&
            !controller.isLeaderboardLoading.value &&
            controller.leaderboardErrorMessage.value.isEmpty) {
          return _buildPersistentStickyBottomBar(controller.leaderboardData.value!.currentUser);
        }
        return const SizedBox.shrink();
      }),
      body: Column(
        children: [
          _buildTabToggle(),
          Expanded(
            child: Obx(() {
              if (controller.activeTab.value == 0) {
                // MY PERFORMANCE
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return _buildErrorWidget();
                }

                if (controller.dashboardData.value == null) {
                  return _buildEmptyWidget();
                }

                final data = controller.dashboardData.value!;
                return RefreshIndicator(
                  onRefresh: () => controller.getDashboardData(),
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsGrid(data),
                        const SizedBox(height: 24),
                        _buildPerformanceChart(data),
                        const SizedBox(height: 24),
                        _buildBestAndLatestSection(data),
                        const SizedBox(height: 24),
                        _buildRecentSubmissions(data.recentSubmissions),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              } else {
                // DAILY LEADERBOARD
                if (controller.isLeaderboardLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.leaderboardErrorMessage.value.isNotEmpty) {
                  return _buildLeaderboardErrorWidget();
                }

                if (controller.leaderboardData.value == null) {
                  return _buildLeaderboardEmptyWidget();
                }

                final leaderboard = controller.leaderboardData.value!;
                return RefreshIndicator(
                  onRefresh: () => controller.getLeaderboardData(),
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLeaderboardHeader(),
                        const SizedBox(height: 16),
                        _buildLeaderboardList(leaderboard),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'My Performance',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.getDashboardData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No quiz attempts yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Start practicing to see your performance here',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DashboardData data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          title: 'Total Score',
          value: '${data.totalScore}',
          subtitle: 'out of ${data.totalPossibleScore}',
          icon: Icons.star_rounded,
          color: AppColors.primary,
          gradient: AppColors.primaryGradient,
        ),
        _StatCard(
          title: 'Accuracy',
          value: '${data.averagePercentage.toStringAsFixed(1)}%',
          subtitle: '${data.correctAnswers} correct',
          icon: Icons.trending_up_rounded,
          color: AppColors.success,
          gradient: const LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
          ),
        ),
        _StatCard(
          title: 'Sets Attempted',
          value: '${data.totalSetsAttempted}',
          subtitle: '${data.totalSubmissions} submissions',
          icon: Icons.assignment_rounded,
          color: const Color(0xFFF59E0B),
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
          ),
        ),
        _StatCard(
          title: 'Questions',
          value: '${data.totalQuestions}',
          subtitle: '${data.correctAnswers}/${data.totalQuestions}',
          icon: Icons.quiz_rounded,
          color: const Color(0xFF8B5CF6),
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart(DashboardData data) {
    final passRate = data.totalSubmissions > 0
        ? (data.passedCount / data.totalSubmissions) * 100
        : 0.0;
    final failRate = data.totalSubmissions > 0
        ? (data.failedCount / data.totalSubmissions) * 100
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, size: 24),
              SizedBox(width: 8),
              Text(
                'Performance Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: CircularProgressIndicator(
                              value: data.averagePercentage / 100,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getScoreColor(data.averagePercentage),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${data.averagePercentage.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Avg',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Average Score',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressBar(
                      'Passed',
                      passRate,
                      AppColors.success,
                      data.passedCount,
                    ),
                    const SizedBox(height: 12),
                    _buildProgressBar(
                      'Failed',
                      failRate,
                      AppColors.error,
                      data.failedCount,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    String label,
    double percentage,
    Color color,
    int count,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              '$count attempts',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildBestAndLatestSection(DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'HIGHLIGHTS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        if (data.bestSubmission != null)
          _HighlightCard(
            title: '🏆 Best Performance',
            submission: data.bestSubmission!,
            isBest: true,
          ),
        const SizedBox(height: 12),
        if (data.latestSubmission != null)
          _HighlightCard(
            title: '🕒 Latest Attempt',
            submission: data.latestSubmission!,
            isBest: false,
          ),
      ],
    );
  }

  Widget _buildRecentSubmissions(List<Submission> submissions) {
    if (submissions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'RECENT ACTIVITY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: submissions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _SubmissionCard(submission: submissions[index]);
          },
        ),
      ],
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return const Color(0xFFF59E0B);
    if (percentage >= 40) return const Color(0xFFF97316);
    return AppColors.error;
  }

  Widget _buildTabToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.activeTab.value = 0,
              child: Obx(() {
                final selected = controller.activeTab.value == 0;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'My Performance',
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected ? AppColors.primary : Colors.grey.shade600,
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.activeTab.value = 1,
              child: Obx(() {
                final selected = controller.activeTab.value == 1;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Daily Leaderboard',
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected ? AppColors.primary : Colors.grey.shade600,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardHeader() {
    final now = DateTime.now();
    final formatter = '${now.day} ${_getMonthName(now.month)}, ${now.year}';

    return Row(
      children: [
        const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          "Today's Standings • $formatter",
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  Widget _buildLeaderboardList(LeaderboardResponse leaderboard) {
    if (leaderboard.topUsers.isEmpty) {
      return _buildLeaderboardEmptyWidget();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leaderboard.topUsers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = leaderboard.topUsers[index];
        return _buildLeaderboardUserRow(user);
      },
    );
  }

  Widget _buildLeaderboardUserRow(LeaderboardUser user) {
    final isTop3 = user.rank >= 1 && user.rank <= 3;
    
    Widget rankIndicator;
    if (user.rank == 1) {
      rankIndicator = const Text('🥇', style: TextStyle(fontSize: 26), textAlign: TextAlign.center);
    } else if (user.rank == 2) {
      rankIndicator = const Text('🥈', style: TextStyle(fontSize: 26), textAlign: TextAlign.center);
    } else if (user.rank == 3) {
      rankIndicator = const Text('🥉', style: TextStyle(fontSize: 26), textAlign: TextAlign.center);
    } else {
      rankIndicator = Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${user.rank}',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      );
    }

    Color avatarColor;
    if (user.rank == 1) {
      avatarColor = const Color(0xFFFBBF24); // Gold
    } else if (user.rank == 2) {
      avatarColor = const Color(0xFF94A3B8); // Silver
    } else if (user.rank == 3) {
      avatarColor = const Color(0xFFD97706); // Bronze
    } else {
      avatarColor = AppColors.primary.withValues(alpha: 0.7);
    }

    final userInitials = _getInitials(user.name);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isTop3 ? avatarColor.withValues(alpha: 0.2) : AppColors.border,
          width: isTop3 ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: rankIndicator,
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor,
            child: Text(
              userInitials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user.email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isTop3 ? avatarColor.withValues(alpha: 0.12) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: isTop3 ? avatarColor : AppColors.textTertiary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${user.score}',
                  style: TextStyle(
                    color: isTop3 ? avatarColor : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersistentStickyBottomBar(LeaderboardUser currentUser) {
    final hasRank = currentUser.rank > 0;
    final userInitials = _getInitials(currentUser.name);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondary, // Dark Slate
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                hasRank ? '#${currentUser.rank}' : '-',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Text(
                userInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'You',
                    style: TextStyle(
                      color: AppColors.textWhite70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    currentUser.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.xpGold,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${currentUser.score} XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              controller.leaderboardErrorMessage.value,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.getLeaderboardData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No scores recorded today',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to complete a quiz today!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'G';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'G';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final LinearGradient gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.1), Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                SizedBox(width: 20),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String title;
  final Submission submission;
  final bool isBest;

  const _HighlightCard({
    required this.title,
    required this.submission,
    required this.isBest,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = submission.scorePercentage;
    final color = isBest ? AppColors.primary : AppColors.secondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.1), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Set ${submission.setNo}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${submission.correctAnswersCount} correct',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.cancel, size: 14, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(
                      '${submission.wrongAnswersCount} wrong',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(percentage),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getScoreColor(percentage).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getScoreLabel(percentage),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getScoreColor(percentage),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return const Color(0xFFF59E0B);
    if (percentage >= 40) return const Color(0xFFF97316);
    return AppColors.error;
  }

  String _getScoreLabel(double percentage) {
    if (percentage >= 80) return 'Excellent';
    if (percentage >= 60) return 'Good';
    if (percentage >= 40) return 'Average';
    return 'Needs Improvement';
  }
}

class _SubmissionCard extends StatelessWidget {
  final Submission submission;

  const _SubmissionCard({required this.submission});

  @override
  Widget build(BuildContext context) {
    final percentage = submission.scorePercentage;
    final scoreColor = _getScoreColor(percentage);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scoreColor.withValues(alpha: 0.2),
                  scoreColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set ${submission.setNo}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${submission.correctAnswersCount}/${submission.answers.length} correct',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getScoreLabel(percentage),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(submission.createdAt),
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return const Color(0xFFF59E0B);
    if (percentage >= 40) return const Color(0xFFF97316);
    return AppColors.error;
  }

  String _getScoreLabel(double percentage) {
    if (percentage >= 80) return 'Excellent';
    if (percentage >= 60) return 'Good';
    if (percentage >= 40) return 'Average';
    return 'Poor';
  }

  String _formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateTimeString;
    }
  }
}
