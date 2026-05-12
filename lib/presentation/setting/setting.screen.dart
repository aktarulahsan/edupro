import 'package:edupro/infrastructure/dal/daos/usersModel.dart';
import 'package:edupro/infrastructure/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'controllers/setting.controller.dart';

class SettingScreen extends GetView<SettingController> {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SettingController>()) {
      Get.put(SettingController());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Obx(() {
          final user = controller.user.value;
          return RefreshIndicator(
            onRefresh: () async => controller.loadUser(),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _ProfileCard(user: user, controller: controller),
                const SizedBox(height: 24),
                _SettingsSection(
                  title: 'ACCOUNT',
                  children: [
                    _SettingsTile(
                      icon: Icons.subscriptions_rounded,
                      title: 'Premium Subscription',
                      subtitle: 'Unlock all features',
                      iconColor: AppColors.primary,
                      trailing: const _PremiumBadge(),
                      onTap: () => _showComingSoon('Subscription'),
                    ),
                    _SettingsTile(
                      icon: Icons.security_rounded,
                      title: 'Account Status',
                      subtitle: user == null
                          ? 'Not signed in'
                          : 'Active account',
                      trailing: _StatusBadge(isActive: user != null),
                      iconColor: user == null
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SettingsSection(
                  title: 'SUPPORT & FEEDBACK',
                  children: [
                    _SettingsTile(
                      icon: Icons.share_rounded,
                      title: 'Share App',
                      subtitle: 'Invite friends to join',
                      onTap: () => shareApp(),
                    ),
                    _SettingsTile(
                      icon: Icons.star_rounded,
                      title: 'Rate Us',
                      subtitle: 'Love our app? Leave a review',
                      // onTap: () => _showComingSoon('Rate App'),
                      onTap: () => _launchUrl(
                        'https://play.google.com/store/apps/details?id=com.aktarulahsan.kuishoudownloader',
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.message_rounded,
                      title: 'Join Community',
                      subtitle: 'Connect on WhatsApp',
                      onTap: () => _launchUrl(
                        'https://chat.whatsapp.com/LEJOZGsYlgW1rAYvDU06tB',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SettingsSection(
                  title: 'INFORMATION',
                  children: [
                    _SettingsTile(
                      icon: Icons.privacy_tip_rounded,
                      title: 'Privacy Policy',
                      subtitle: 'How we protect your data',
                      onTap: () => _showComingSoon('Privacy Policy'),
                    ),
                    _SettingsTile(
                      icon: Icons.info_rounded,
                      title: 'About Us',
                      subtitle: 'Learn more about EduPro',
                      onTap: () =>
                          _launchUrl('https://eduproskill.blogspot.com/'),
                    ),
                    _SettingsTile(
                      icon: Icons.grid_view_rounded,
                      title: 'More Apps',
                      subtitle: 'Discover our other products',
                      onTap: () => _launchUrl(
                        'https://play.google.com/store/apps/dev?id=6882414058319286041',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
    );
  }

  void shareApp() {
    // Share.share(
    //   'Check out this awesome app: Kuishu Downloader\nDownload it from the Play Store: https://play.google.com/store/apps/details?id=com.aktarulahsan.kuishoudownloader',
    // );
    SharePlus.instance.share(ShareParams(text: 'Check out this awesome app'));
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Settings',
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

  void _showComingSoon(String title) {
    Get.snackbar(
      title,
      'This feature will be available in the next update! 🚀',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.favorite, color: Colors.white),
    );
  }

  // Future<void> _launchUrl(String url) async {
  //   final Uri uri = Uri.parse(url);
  //   try {
  //     if (await canLaunchUrl(uri)) {
  //       await launchUrl(uri, mode: LaunchMode.externalApplication);
  //     } else {
  //       throw 'Could not launch $url';
  //     }
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'Unable to open link. Please try again.',
  //       snackPosition: SnackPosition.BOTTOM,
  //       margin: const EdgeInsets.all(16),
  //       borderRadius: 16,
  //       backgroundColor: AppColors.error,
  //       colorText: Colors.white,
  //       duration: const Duration(seconds: 2),
  //     );
  //   }
  // }
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);

    // Add force browser parameter for Blogspot
    final finalUri = url.contains('blogspot.com')
        ? Uri.parse('$url?force=1')
        : uri;

    try {
      await launchUrl(
        finalUri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } catch (e) {
      // Manual fallback
      // _showManualOpenDialog(url);
    }
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user, required this.controller});

  final UserModel? user;
  final SettingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _ProfileAvatar(user: user),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayName(user),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (user?.emailAddress != null) ...[
                    Text(
                      user!.emailAddress!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      _ActionChip(
                        label: 'Sign Out',
                        icon: Icons.logout_rounded,
                        color: AppColors.error,
                        onTap: controller.signOut,
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayName(UserModel? user) {
    final fullName = [
      user?.fristName,
      user?.lastName,
    ].where((part) => part != null && part.trim().isNotEmpty).join(' ');

    if (fullName.isNotEmpty) return fullName;
    if (user?.emailAddress != null) {
      return user!.emailAddress!.split('@').first;
    }
    return 'Guest User';
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final imageUrl = user?.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white,
        backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
        child: hasImage
            ? null
            : Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      avatar: Icon(icon, size: 18, color: color),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.05),
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle_rounded : Icons.error_rounded,
            color: isActive ? AppColors.success : AppColors.warning,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              color: isActive ? AppColors.success : AppColors.warning,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
