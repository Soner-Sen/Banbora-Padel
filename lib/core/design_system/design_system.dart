import 'package:flutter/material.dart';

abstract final class AppSpacing {
  AppSpacing._();

  // 8pt base scale (doubled from 4pt)
  static const double xxs = 8; // was 4
  static const double xs = 16; // was 8
  static const double sm = 24; // was 12
  static const double md = 32; // was 16
  static const double lg = 40; // was 20
  static const double xl = 48; // was 24
  static const double xxl = 64; // was 32
  static const double xxxl = 80; // was 40
  static const double touchMin = 48;
  static const double buttonHeight = 56;

  // Legacy aliases for backwards compatibility
  static const double spacing4 = xxs;
  static const double spacing8 = xs;
  static const double spacing12 = sm;
  static const double spacing16 = md;
  static const double spacing20 = lg;
  static const double spacing24 = xl;
  static const double spacing32 = xxl;
}

abstract final class AppRadius {
  AppRadius._();

  static const double sm = 10; // Small inputs
  static const double md = 14; // Input fields
  static const double lg = 20; // Buttons (was 18)
  static const double xl = 24; // Cards (was 18)
  static const double xxl = 32; // Bottom sheets (was 24)
  static const double pill = 999; // Pills, chips

  // Component aliases
  static const double card = xl; // 24px
  static const double button = lg; // 20px
  static const double bottomSheet = xxl; // 32px

  // Legacy aliases
  static const double borderRadius8 = sm;
  static const double borderRadius10 = md;
  static const double borderRadius14 = md;
  static const double borderRadius18 = lg;
  static const double borderRadius24 = xl;
}

// Light & Airy color palette with Tinted Neutrals
abstract final class AppColors {
  AppColors._();

  // === BACKGROUND (Tinted Neutrals - Augen schonend) ===
  // Mint-Grau statt kaltem Stone - reduziert Blaullicht
  static const Color canvas = Color(0xFFF0F4F2); // mattes Mint-Grau
  static const Color surface = Color(
    0xFFFFFFFF,
  ); // Weiß nur für Highlight-Cards
  static const Color elevated = Color(
    0xFFE8EEE9,
  ); // Leicht grünstichig für Tiefe
  static const Color surfaceVariant = elevated;

  // === PRIMARY / EMERALD (Deeper für mehr presence) ===
  static const Color primary = Color(
    0xFF065F46,
  ); // emerald-800 (seriöser, sportlicher)
  static const Color primaryPressed = Color(0xFF047857); // emerald-700
  static const Color primaryLight = Color(
    0xFF10B981,
  ); // emerald-500 für Akzente
  static const Color onPrimary = Color(0xFFFFFFFF); // white text on primary

  // === SECONDARY ===
  static const Color secondary = Color(0xFF4A5D55); // Muted Forest
  static const Color muted = Color(0xFF788C83); // Text Muted

  // === TEXT (Softer Kontrast - Deep Forest statt Slate) ===
  // Wirkt fast schwarz, aber viel angenehmer für die Augen
  static const Color textPrimary = Color(0xFF1A2E26); // Deep Forest Green
  static const Color textSecondary = Color(0xFF4A5D55); // Muted Forest
  static const Color textMuted = Color(0xFF788C83); // Light Muted
  static const Color textTertiary = textMuted;

  // === TEAMS (Ocean Blue + Ember Orange - Blau-Grün-Blind freundlich) ===
  static const Color teamA = Color(0xFF0077B6); // ocean electric blue
  static const Color teamB = Color(0xFFE85D04); // ember orange

  // === STATUS (Grape Green nur für Winner, Server dezent) ===
  static const Color winner = Color(0xFF059669); // grape green
  static const Color server = Color(0xFF6366F1); // indigo-500
  static const Color serverGlow = Color(0xFFE0E7FF); // indigo-100

  // === COURT (PRESERVED - Sacred per Agustín & Arturo) ===
  static const Color courtBase = Color(0xFF0F6D64); // teal-700
  static const Color courtLine = Color(0xFFE2E8F0); // slate-200 (was DCE7F5)
  static const Color courtNet = Color(0xFF64748B); // slate-500
  static const Color accentMint = Color(
    0xFFD1FAE5,
  ); // Für sanfte Hintergründe in Badges

  // === UTILITY ===
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // === LEGACY ALIASES (for existing code compatibility) ===
  static const Color orbitPrimary = primary;
  static const Color orbitPrimaryPressed = primaryPressed;
  static const Color orbitOnPrimary = onPrimary;
  static const Color accentAmber = teamB;
}

abstract final class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration scoreFeedback = Duration(milliseconds: 100);
}

// Soft UI / Claymorphism shadows (replacing elevation numbers)
// Hint of primary color makes shadows feel "alive"
class AppShadows {
  AppShadows._();

  // low = 24px blur, 5% opacity - Cards at rest
  static List<BoxShadow> get low => [
    BoxShadow(
      color: const Color(0xFF065F46).withValues(alpha: 0.05), // Hint of primary
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // medium = 32px blur, 8% opacity - Dropdowns, popovers
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: const Color(0xFF065F46).withValues(alpha: 0.08),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  // high = 48px blur, 10% opacity - Modals, dialogs
  static List<BoxShadow> get high => [
    BoxShadow(
      color: const Color(0xFF065F46).withValues(alpha: 0.10),
      blurRadius: 48,
      offset: const Offset(0, 20),
    ),
  ];

  static const List<BoxShadow> none = [];
}

// AppElevation now references shadows for consistency
abstract final class AppElevation {
  AppElevation._();

  static const List<BoxShadow> none = [];
  static List<BoxShadow> get low => AppShadows.low;
  static List<BoxShadow> get medium => AppShadows.medium;
  static List<BoxShadow> get high => AppShadows.high;
}

class DesignTokens {
  const DesignTokens._();

  // Spacing
  static const double spacing4 = AppSpacing.spacing4;
  static const double spacing8 = AppSpacing.spacing8;
  static const double spacing12 = AppSpacing.spacing12;
  static const double spacing16 = AppSpacing.spacing16;
  static const double spacing20 = AppSpacing.spacing20;
  static const double spacing24 = AppSpacing.spacing24;
  static const double spacing32 = AppSpacing.spacing32;
  static const double spacing48 = 48;
  static const double spacing = spacing16;

  // Radius
  static const double borderRadius8 = AppRadius.borderRadius8;
  static const double borderRadius10 = AppRadius.borderRadius10;
  static const double borderRadius14 = AppRadius.borderRadius14;
  static const double borderRadius18 = AppRadius.borderRadius18;
  static const double borderRadius24 = AppRadius.borderRadius24;

  // Colors - Light & Airy palette
  static const Color primary = AppColors.primary;
  static const Color secondary = AppColors.secondary;
  static const Color onPrimary = AppColors.onPrimary;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textTertiary = AppColors.textTertiary;
  static const Color surface = AppColors.surface;
  static const Color elevated = AppColors.elevated;
  static const Color surfaceVariant = AppColors.surfaceVariant;
  static const Color canvas = AppColors.canvas;
  static const Color error = AppColors.error;
  static const Color info = AppColors.info;
  static const Color warning = AppColors.warning;
  static const Color success = AppColors.success;
  static const Color muted = AppColors.muted;

  // Orbit colors (legacy aliases)
  static const Color orbitPrimary = AppColors.orbitPrimary;
  static const Color orbitPrimaryPressed = AppColors.orbitPrimaryPressed;
  static const Color orbitOnPrimary = AppColors.orbitOnPrimary;

  // Text colors
  static const Color textMuted = AppColors.textMuted;

  // Team colors
  static const Color teamA = AppColors.teamA;
  static const Color teamB = AppColors.teamB;

  // Court colors (PRESERVED)
  static const Color courtBase = AppColors.courtBase;
  static const Color courtLine = AppColors.courtLine;
  static const Color courtNet = AppColors.courtNet;

  // Elevation (now shadows)
  static const List<BoxShadow> elevationNone = [];
  static List<BoxShadow> get elevationLow => AppElevation.low;
  static List<BoxShadow> get elevationMedium => AppElevation.medium;
  static List<BoxShadow> get elevationHigh => AppElevation.high;

  // Legacy textOnPrimary alias
  static const Color textOnPrimary = AppColors.onPrimary;
}
