import 'package:flutter/material.dart';

class AppColors {
  // ==============================================
  // PROFESSIONAL COLOR SCHEME BASED ON #68F09A
  // Theme: "Fresh Mint & Deep Navy"
  // ==============================================

  // Primary Brand Colors - Mint Green palette
  static const Color primary = Color(0xFF68F09A);     // Fresh Mint Green - Main brand color
  static const Color primaryDark = Color(0xFF4AC97A);  // Darker mint for pressed states
  static const Color primaryLight = Color(0xFF8AF4B0); // Light mint for highlights
  static const Color primaryBackground = Color(0xFFE8FCF0); // Very light mint for backgrounds
  static const Color primaryVariant = Color(0xFF34D873); // Vibrant mint variant

  // Secondary Colors - Deep Navy Blue (creates professional contrast)
  static const Color secondary = Color(0xFF1A2B4C);     // Deep Navy - Main secondary
  static const Color secondaryLight = Color(0xFF2D4A6E); // Lighter navy
  static const Color secondaryDark = Color(0xFF0F1A33);  // Darker navy
  static const Color secondaryVariant = Color(0xFF243B5E); // Navy variant

  // Accent Colors - Coral/Peach (warm contrast to mint)
  static const Color accent = Color(0xFFF27A5E);        // Coral Peach - Call to action
  static const Color accentLight = Color(0xFFF6A08A);   // Light coral
  static const Color accentDark = Color(0xFFE05A3A);    // Dark coral
  static const Color accentVariant = Color(0xFFF48B71); // Coral variant

  // Text Colors - High contrast for readability
  static const Color textPrimary = Color(0xFF1A2B4C);    // Deep Navy - Main text
  static const Color textSecondary = Color(0xFF4A5568);  // Slate Gray - Secondary text
  static const Color textTertiary = Color(0xFFA0AEC0);   // Light gray - Tertiary text
  static const Color textWhite = Color(0xFFFFFFFF);      // White text
  static const Color textWhite70 = Color(0xB3FFFFFF);    // White with 70% opacity
  static const Color textOnPrimary = Color(0xFF1A2B4C);   // Text on primary (dark for contrast)
  static const Color textOnSecondary = Color(0xFFFFFFFF); // Text on secondary (white)
  static const Color textOnAccent = Color(0xFFFFFFFF);    // Text on accent (white)

  // Background Colors - Clean and modern
  static const Color background = Color(0xFFF7FAFC);     // Very light gray - Main background
  static const Color backgroundWhite = Color(0xFFFFFFFF); // Pure white - Cards
  static const Color backgroundDark = Color(0xFF1A2B4C);   // Deep Navy - Dark mode
  static const Color backgroundSecondary = Color(0xFFEDF2F7); // Light gray-blue
  static const Color backgroundMint = Color(0xFFE8FCF0);  // Light mint background

  // Status Colors - Clear and intuitive
  static const Color success = Color(0xFF10B981);        // Emerald Green - Success
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);        // Amber - Warning
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);          // Red - Error
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);           // Blue - Info
  static const Color infoLight = Color(0xFF60A5FA);

  // XP and Progress Colors - Engaging and motivating
  static const Color xpGold = Color(0xFFFBBF24);         // Gold - XP stars
  static const Color xpPlatinum = Color(0xFF94A3B8);     // Platinum - High level
  static const Color xpDiamond = Color(0xFF38BDF8);      // Diamond - Elite level
  static const Color xpBronze = Color(0xFFD97706);       // Bronze - Beginner level
  static const Color progressBar = Color(0xFF68F09A);    // Mint - Progress bar
  static const Color progressBackground = Color(0xFFE2E8F0); // Light gray - Progress background

  // Border and Divider Colors - Subtle separation
  static const Color border = Color(0xFFE2E8F0);         // Light border
  static const Color borderDark = Color(0xFFCBD5E1);     // Darker border
  static const Color divider = Color(0xFFF1F5F9);        // Divider line

  // Gradient Colors - Stunning gradients for visual appeal
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF68F09A), Color(0xFF34D873)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2B4C), Color(0xFF2D4A6E)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF27A5E), Color(0xFFE05A3A)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF7FAFC)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF68F09A), Color(0xFF1A2B4C), Color(0xFFF27A5E)],
  );

  static const LinearGradient mintToNavyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF68F09A), Color(0xFF1A2B4C)],
  );

  // Shadow Colors - Modern depth
  static const Color shadowLight = Color(0x0D000000);     // Light shadow (5% opacity)
  static const Color shadowMedium = Color(0x1A000000);    // Medium shadow (10% opacity)
  static const Color shadowDark = Color(0x33000000);      // Dark shadow (20% opacity)

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

  // Dark Mode Colors - Optimized for dark theme with mint accents
  static const Map<String, Color> darkMode = {
    'primary': Color(0xFF68F09A),
    'primaryDark': Color(0xFF4AC97A),
    'secondary': Color(0xFF2D4A6E),
    'accent': Color(0xFFF48B71),
    'background': Color(0xFF0F172A),
    'surface': Color(0xFF1A2B4C),
    'text': Color(0xFFF1F5F9),
    'textSecondary': Color(0xFF94A3B8),
  };

  // Additional Professional Colors
  static const Color professionalBlue = Color(0xFF2563EB);
  static const Color professionalNavy = Color(0xFF1A2B4C);
  static const Color professionalGold = Color(0xFFD97706);
  static const Color professionalRose = Color(0xFFE11D48);
  static const Color professionalTeal = Color(0xFF0D9488);
}

// Extension for easy theme access
extension ThemeColorExtension on BuildContext {
  AppColors get colors => AppColors();
}

// Optional: Pre-defined color schemes for different moods based on #68F09A
class ColorSchemes {
  // Scheme 1: Mint & Navy (Professional & Fresh) - DEFAULT
  static const Map<String, Color> mintAndNavy = {
    'primary': Color(0xFF68F09A),
    'secondary': Color(0xFF1A2B4C),
    'accent': Color(0xFFF27A5E),
  };

  // Scheme 2: Mint & Purple (Creative & Modern)
  static const Map<String, Color> mintAndPurple = {
    'primary': Color(0xFF68F09A),
    'secondary': Color(0xFF6D28D9),
    'accent': Color(0xFFF59E0B),
  };

  // Scheme 3: Mint & Rose Gold (Elegant & Premium)
  static const Map<String, Color> mintAndRose = {
    'primary': Color(0xFF68F09A),
    'secondary': Color(0xFFBE123C),
    'accent': Color(0xFFFBBF24),
  };

  // Scheme 4: Mint & Ocean (Calm & Trustworthy)
  static const Map<String, Color> mintAndOcean = {
    'primary': Color(0xFF68F09A),
    'secondary': Color(0xFF0891B2),
    'accent': Color(0xFFF97316),
  };

  // Scheme 5: Mint & Slate (Minimal & Corporate)
  static const Map<String, Color> mintAndSlate = {
    'primary': Color(0xFF68F09A),
    'secondary': Color(0xFF334155),
    'accent': Color(0xFF3B82F6),
  };
}



const kPrimary = Color(0xFF1A6B5A);
const kPrimaryLight = Color(0xFFE8F5F1);
const kBackground = Color(0xFFF5F7F9);
const kCardBg = Color(0xFFFFFFFF);
const kTextDark = Color(0xFF1A2B3C);
const kTextGrey = Color(0xFF6B7C8D);
const kDivider = Color(0xFFE8EDF2);
const Color darkBlue = Color(0xFF1976D2);