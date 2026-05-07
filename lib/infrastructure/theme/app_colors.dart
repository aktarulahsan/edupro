import 'package:flutter/material.dart';

class AppColors {
  // ==============================================
  // PROFESSIONAL COLOR SCHEME - BCS Blue Theme
  // Theme: "Professional Blue & Dark Slate"
  // ==============================================

  // Primary Brand Colors - Professional Blue palette
  static const Color primary = Color(
    0xFF4A90E2,
  ); // Professional Blue - Main brand color
  static const Color primaryDark = Color(
    0xFF357ABD,
  ); // Darker blue for pressed states
  static const Color primaryLight = Color(
    0xFF6FA5E8,
  ); // Light blue for highlights
  static const Color primaryBackground = Color(
    0xFFE8F1F9,
  ); // Very light blue for backgrounds
  static const Color primaryVariant = Color(0xFF357ABD); // Blue variant

  // Secondary Colors - Dark Slate (creates professional contrast)
  static const Color secondary = Color(
    0xFF2C3E50,
  ); // Dark Slate - Main secondary
  static const Color secondaryLight = Color(0xFF3D5468); // Lighter slate
  static const Color secondaryDark = Color(0xFF1A2535); // Darker slate
  static const Color secondaryVariant = Color(0xFF34495E); // Slate variant

  // Accent Colors - Purple & Orange (warm contrast)
  static const Color accent = Color(0xFF9C27B0); // Purple - Call to action
  static const Color accentLight = Color(0xFFAB47BC); // Light purple
  static const Color accentDark = Color(0xFF7B1FA2); // Dark purple
  static const Color accentVariant = Color(0xFFFF9800); // Orange variant

  // Text Colors - High contrast for readability
  static const Color textPrimary = Color(0xFF2C3E50); // Dark Slate - Main text
  static const Color textSecondary = Color(
    0xFF5A6C7D,
  ); // Medium Gray - Secondary text
  static const Color textTertiary = Color(
    0xFF9CA3AF,
  ); // Light gray - Tertiary text
  static const Color textWhite = Color(0xFFFFFFFF); // White text
  static const Color textWhite70 = Color(0xB3FFFFFF); // White with 70% opacity
  static const Color textOnPrimary = Color(
    0xFFFFFFFF,
  ); // Text on primary (white)
  static const Color textOnSecondary = Color(
    0xFFFFFFFF,
  ); // Text on secondary (white)
  static const Color textOnAccent = Color(0xFFFFFFFF); // Text on accent (white)

  // Background Colors - Clean and modern
  static const Color background = Color(
    0xFFF8F9FA,
  ); // Very light gray - Main background
  static const Color backgroundWhite = Color(0xFFFFFFFF); // Pure white - Cards
  static const Color appBarBackground = backgroundWhite;
  static const Color appBarForeground = textPrimary;
  static const Color backgroundDark = Color(
    0xFF2C3E50,
  ); // Dark slate - Dark mode
  static const Color backgroundSecondary = Color(0xFFE8ECF0); // Light gray
  static const Color backgroundMint = Color(
    0xFFE8F1F9,
  ); // Light blue background

  // Status Colors - Clear and intuitive
  static const Color success = Color(0xFF4CAF50); // Green - Success
  static const Color successLight = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFF9800); // Orange - Warning
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color error = Color(0xFFEF4444); // Red - Error
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF4A90E2); // Blue - Info
  static const Color infoLight = Color(0xFF64B5F6);

  // XP and Progress Colors - Engaging and motivating
  static const Color xpGold = Color(0xFFFBBF24); // Gold - XP stars
  static const Color xpPlatinum = Color(0xFF94A3B8); // Platinum - High level
  static const Color xpDiamond = Color(0xFF38BDF8); // Diamond - Elite level
  static const Color xpBronze = Color(0xFFD97706); // Bronze - Beginner level
  static const Color progressBar = Color(0xFF4A90E2); // Blue - Progress bar
  static const Color progressBackground = Color(
    0xFFE8ECF0,
  ); // Light gray - Progress background

  // Border and Divider Colors - Subtle separation
  static const Color border = Color(0xFFE8ECF0); // Light border
  static const Color borderDark = Color(0xFFD1D5DB); // Darker border
  static const Color divider = Color(0xFFE8ECF0); // Divider line

  // Gradient Colors - Stunning gradients for visual appeal
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2C3E50), Color(0xFF3D5468)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A90E2), Color(0xFF2C3E50), Color(0xFF9C27B0)],
  );

  static const LinearGradient blueToSlateGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A90E2), Color(0xFF2C3E50)],
  );

  // Shadow Colors - Modern depth
  static const Color shadowLight = Color(
    0x0D000000,
  ); // Light shadow (5% opacity)
  static const Color shadowMedium = Color(
    0x1A000000,
  ); // Medium shadow (10% opacity)
  static const Color shadowDark = Color(
    0x33000000,
  ); // Dark shadow (20% opacity)

  // Card and Surface Colors
  static const Color card = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7FAFC);
  static const Color surfaceVariant = Color(0xFFEDF2F7);

  // Opacity Helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Shimmer Colors for loading states
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF1F5F9);

  // Dark Mode Colors - Optimized for dark theme with blue accents
  static const Map<String, Color> darkMode = {
    'primary': Color(0xFF4A90E2),
    'primaryDark': Color(0xFF357ABD),
    'secondary': Color(0xFF3D5468),
    'accent': Color(0xFF9C27B0),
    'background': Color(0xFF0F172A),
    'surface': Color(0xFF1A2B4C),
    'text': Color(0xFFF1F5F9),
    'textSecondary': Color(0xFFB4BCC9),
  };

  // Additional Professional Colors
  static const Color professionalBlue = Color(0xFF4A90E2);
  static const Color professionalSlate = Color(0xFF2C3E50);
  static const Color professionalPurple = Color(0xFF9C27B0);
  static const Color professionalGold = Color(0xFFFF9800);
  static const Color professionalGreen = Color(0xFF4CAF50);
}

// Extension for easy theme access
extension ThemeColorExtension on BuildContext {
  AppColors get colors => AppColors();
}

// Optional: Pre-defined color schemes for different moods
class ColorSchemes {
  // Scheme 1: Professional Blue & Slate (DEFAULT)
  static const Map<String, Color> blueAndSlate = {
    'primary': Color(0xFF4A90E2),
    'secondary': Color(0xFF2C3E50),
    'accent': Color(0xFF9C27B0),
  };

  // Scheme 2: Blue & Orange (Warm & Energetic)
  static const Map<String, Color> blueAndOrange = {
    'primary': Color(0xFF4A90E2),
    'secondary': Color(0xFF2C3E50),
    'accent': Color(0xFFFF9800),
  };

  // Scheme 3: Blue & Green (Fresh & Professional)
  static const Map<String, Color> blueAndGreen = {
    'primary': Color(0xFF4A90E2),
    'secondary': Color(0xFF2C3E50),
    'accent': Color(0xFF4CAF50),
  };

  // Scheme 4: Blue & Purple (Creative & Modern)
  static const Map<String, Color> blueAndPurple = {
    'primary': Color(0xFF4A90E2),
    'secondary': Color(0xFF2C3E50),
    'accent': Color(0xFF9C27B0),
  };

  // Scheme 5: Blue & Coral (Elegant & Premium)
  static const Map<String, Color> blueAndCoral = {
    'primary': Color(0xFF4A90E2),
    'secondary': Color(0xFF2C3E50),
    'accent': Color(0xFFF87171),
  };
}

// Legacy constants - mapped to new palette
const Color kBaseColor = AppColors.primary;
// const Color kPrimary = AppColors.primary;
// const Color kPrimaryLight = AppColors.primaryLight;
const Color kBackground = AppColors.background;
// const Color kCardBg = AppColors.backgroundWhite;
// const Color kTextDark = AppColors.textPrimary;
// const Color kTextGrey = AppColors.textSecondary;
// const Color kDivider = AppColors.divider;
// const Color darkBlue = AppColors.secondary;

const kPrimary = Color(0xFF1A6B5A);
const kPrimaryLight = Color(0xFFE8F5F1);
// const kBackground = Color(0xFFF5F7F9);
const kCardBg = Color(0xFFFFFFFF);
const kTextDark = Color(0xFF1A2B3C);
const kTextGrey = Color(0xFF6B7C8D);
const kDivider = Color(0xFFE8EDF2);
const Color darkBlue = Color(0xFF1976D2);
