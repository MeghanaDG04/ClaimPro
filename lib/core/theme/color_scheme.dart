import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF2E4A6F);
  static const Color primaryDark = Color(0xFF0E2A4F);

  // Secondary Colors
  static const Color secondary = Color(0xFF0D9488);
  static const Color secondaryLight = Color(0xFF14B8A6);
  static const Color secondaryDark = Color(0xFF0F766E);

  // Accent Colors
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentDark = Color(0xFFD97706);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF97316);
  static const Color warningLight = Color(0xFFFED7AA);
  static const Color warningDark = Color(0xFFEA580C);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);

  // Surface Colors - Light Theme
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color background = Color(0xFFF1F5F9);
  static const Color scaffoldBackground = Color(0xFFF8FAFC);

  // Surface Colors - Dark Theme
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color scaffoldBackgroundDark = Color(0xFF1E293B);

  // Text Colors - Light Theme
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);

  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textHintDark = Color(0xFF64748B);
  static const Color textDisabledDark = Color(0xFF475569);

  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF334155);

  // Claim Status Colors
  static const Color claimPending = Color(0xFFF59E0B);
  static const Color claimPendingBg = Color(0xFFFEF3C7);
  static const Color claimUnderReview = Color(0xFF3B82F6);
  static const Color claimUnderReviewBg = Color(0xFFDBEAFE);
  static const Color claimApproved = Color(0xFF10B981);
  static const Color claimApprovedBg = Color(0xFFD1FAE5);
  static const Color claimRejected = Color(0xFFEF4444);
  static const Color claimRejectedBg = Color(0xFFFEE2E2);
  static const Color claimProcessing = Color(0xFF8B5CF6);
  static const Color claimProcessingBg = Color(0xFFEDE9FE);
  static const Color claimClosed = Color(0xFF6B7280);
  static const Color claimClosedBg = Color(0xFFF3F4F6);

  // Priority Colors
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF10B981);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x40000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successLight],
  );

  static ColorScheme get lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryLight,
        onPrimaryContainer: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        secondaryContainer: secondaryLight,
        onSecondaryContainer: Colors.white,
        tertiary: accent,
        onTertiary: Colors.white,
        tertiaryContainer: accentLight,
        onTertiaryContainer: textPrimary,
        error: error,
        onError: Colors.white,
        errorContainer: errorLight,
        onErrorContainer: errorDark,
        surface: surface,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceVariant,
        onSurfaceVariant: textSecondary,
        outline: border,
        outlineVariant: divider,
        shadow: shadow,
        scrim: overlay,
        inverseSurface: backgroundDark,
        onInverseSurface: textPrimaryDark,
        inversePrimary: secondaryLight,
      );

  static ColorScheme get darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: secondary,
        onPrimary: Colors.white,
        primaryContainer: secondaryDark,
        onPrimaryContainer: Colors.white,
        secondary: primary,
        onSecondary: Colors.white,
        secondaryContainer: primaryDark,
        onSecondaryContainer: Colors.white,
        tertiary: accentLight,
        onTertiary: textPrimary,
        tertiaryContainer: accent,
        onTertiaryContainer: Colors.white,
        error: errorLight,
        onError: errorDark,
        errorContainer: error,
        onErrorContainer: Colors.white,
        surface: surfaceDark,
        onSurface: textPrimaryDark,
        surfaceContainerHighest: surfaceVariantDark,
        onSurfaceVariant: textSecondaryDark,
        outline: borderDark,
        outlineVariant: dividerDark,
        shadow: shadowDark,
        scrim: overlay,
        inverseSurface: surface,
        onInverseSurface: textPrimary,
        inversePrimary: primary,
      );
}
