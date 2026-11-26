import 'package:material_ui/material_ui.dart';

/// Semantic color tokens exposed via [ThemeExtension] for Light and Pure-Black Dark modes.
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.primary,
    required this.onPrimary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.chipBackground,
    required this.chipForeground,
  });

  final Color primary;
  final Color onPrimary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color chipBackground;
  final Color chipForeground;

  static const AppThemeColors light = AppThemeColors(
    primary: Color(0xFF2563EB),
    onPrimary: Color(0xFFFFFFFF),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF1F5F9),
    border: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    chipBackground: Color(0xFFEFF6FF),
    chipForeground: Color(0xFF1D4ED8),
  );

  static const AppThemeColors dark = AppThemeColors(
    primary: Color(0xFF3B82F6),
    onPrimary: Color(0xFFFFFFFF),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
    surface: Color(0xFF0D1117),
    surfaceElevated: Color(0xFF161B22),
    border: Color(0xFF1F2937),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9CA3AF),
    chipBackground: Color(0x293B82F6),
    chipForeground: Color(0xFF93C5FD),
  );

  static AppThemeColors of(BuildContext context) {
    return Theme.of(context).extension<AppThemeColors>() ??
        (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  @override
  AppThemeColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? chipBackground,
    Color? chipForeground,
  }) {
    return AppThemeColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      chipBackground: chipBackground ?? this.chipBackground,
      chipForeground: chipForeground ?? this.chipForeground,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      chipForeground: Color.lerp(chipForeground, other.chipForeground, t)!,
    );
  }
}

/// Application color palette for Light and True Pure-Black Dark themes.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryGradientStart = Color(0xFF3B82F6);
  static const Color primaryGradientEnd = Color(0xFF1D4ED8);
  static const Color primaryDark = Color(0xFF3B82F6);
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color accent = Color(0xFF10B981);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientEnd],
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
  );

  // Semantic Match & Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Light Soft Tints
  static const Color softBlueBg = Color(0xFFEFF6FF);
  static const Color softBlueText = Color(0xFF1D4ED8);
  static const Color softGreenBg = Color(0xFFECFDF5);
  static const Color softAmberBg = Color(0xFFFFFBEB);
  static const Color softRedBg = Color(0xFFFEF2F2);

  // Light Surfaces
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // True Pure-Black Dark Surfaces
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF0D1117);
  static const Color darkSurfaceVariant = Color(0xFF161B22);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF1F2937);

  static Color matchColor(int percentage) {
    if (percentage >= 80) return success;
    if (percentage >= 50) return primary;
    return error;
  }

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color softBlue(BuildContext context) =>
      AppThemeColors.of(context).chipBackground;

  static Color softBlueFg(BuildContext context) =>
      AppThemeColors.of(context).chipForeground;

  static Color softGreen(BuildContext context) =>
      isDark(context) ? success.withValues(alpha: 0.16) : softGreenBg;

  static Color softAmber(BuildContext context) =>
      isDark(context) ? warning.withValues(alpha: 0.16) : softAmberBg;

  static Color softNeutral(BuildContext context) =>
      AppThemeColors.of(context).surfaceElevated;
}
