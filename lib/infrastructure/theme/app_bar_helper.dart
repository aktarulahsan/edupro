import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Unified AppBar builder for consistent UI across all screens
class AppBarHelper {
  /// Build a standard app bar with title
  static PreferredSizeWidget buildAppBar({
    required String title,
    BuildContext? context,
    List<Widget>? actions,
    bool centerTitle = false,
    VoidCallback? onSettingsTap,
  }) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: AppColors.appBarForeground,
        ),
      ),
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: AppColors.appBarBackground,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      actions:
          actions ??
          [
            if (onSettingsTap != null)
              IconButton(
                onPressed: onSettingsTap,
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.appBarForeground,
                ),
                tooltip: 'Settings',
              ),
            const SizedBox(width: 8),
          ],
    );
  }

  /// Build app bar with custom background and gradient
  static PreferredSizeWidget buildGradientAppBar({
    required String title,
    LinearGradient? gradient,
    List<Widget>? actions,
    bool centerTitle = false,
    VoidCallback? onSettingsTap,
  }) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: AppColors.appBarForeground,
        ),
      ),
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: AppColors.appBarBackground,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      actions:
          actions ??
          [
            if (onSettingsTap != null)
              IconButton(
                onPressed: onSettingsTap,
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.appBarForeground,
                ),
                tooltip: 'Settings',
              ),
            const SizedBox(width: 8),
          ],
    );
  }

  /// Build simple app bar without actions
  static PreferredSizeWidget buildSimpleAppBar({
    required String title,
    bool centerTitle = false,
  }) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: AppColors.appBarForeground,
        ),
      ),
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: AppColors.appBarBackground,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  /// Build app bar with back button
  static PreferredSizeWidget buildBackAppBar({
    required String title,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
  }) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.appBarForeground,
        ),
      ),
      elevation: 0,
      backgroundColor: AppColors.appBarBackground,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        onPressed: onBackPressed,
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.appBarForeground,
        ),
      ),
      actions: actions,
    );
  }
}
