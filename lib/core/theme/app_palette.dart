import 'package:flutter/material.dart';

class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surface;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;

  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color secondary;
  final Color tertiary;

  final Color onBackground;
  final Color onSurface;
  final Color onSurfaceDim;

  final Color outline;
  final Color outlineVariant;

  final Color error;
  final Color success;
  final Color warning;
  final Color gold;
  final Color premium;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.secondary,
    required this.tertiary,
    required this.onBackground,
    required this.onSurface,
    required this.onSurfaceDim,
    required this.outline,
    required this.outlineVariant,
    this.error = const Color(0xFFFF4D6D),
    this.success = const Color(0xFF4ADE80),
    this.warning = const Color(0xFFFBBF24),
    this.gold = const Color(0xFFFFD700),
    this.premium = const Color(0xFFFFAA00),
  });

  LinearGradient get primaryGradient => LinearGradient(
        colors: [primaryDark, primary, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient bannerGradient(Color color) => LinearGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.7),
          background,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? secondary,
    Color? tertiary,
    Color? onBackground,
    Color? onSurface,
    Color? onSurfaceDim,
    Color? outline,
    Color? outlineVariant,
    Color? error,
    Color? success,
    Color? warning,
    Color? gold,
    Color? premium,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      onBackground: onBackground ?? this.onBackground,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceDim: onSurfaceDim ?? this.onSurfaceDim,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      gold: gold ?? this.gold,
      premium: premium ?? this.premium,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerHigh:
          Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceDim: Color.lerp(onSurfaceDim, other.onSurfaceDim, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
    );
  }
}
