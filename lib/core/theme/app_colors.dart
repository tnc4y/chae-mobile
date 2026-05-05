import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0A0A0F);
  static const surface = Color(0xFF13131A);
  static const surfaceContainer = Color(0xFF1C1C28);
  static const surfaceContainerHigh = Color(0xFF252535);

  static const primary = Color(0xFF9B72CF);
  static const primaryDark = Color(0xFF7B55AF);
  static const primaryLight = Color(0xFFBB9AEF);

  static const secondary = Color(0xFFE879F9);
  static const tertiary = Color(0xFF22D3EE);

  static const error = Color(0xFFFF4D6D);
  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFBBF24);

  static const onBackground = Color(0xFFF0F0F5);
  static const onSurface = Color(0xFFC8C8D5);
  static const onSurfaceDim = Color(0xFF8E8E9A);

  static const outline = Color(0xFF3A3A4E);
  static const outlineVariant = Color(0xFF2A2A3A);

  static const gold = Color(0xFFFFD700);
  static const premium = Color(0xFFFFAA00);

  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryDark, primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient bannerGradient(Color color) => LinearGradient(
    colors: [
      color.withValues(alpha: 0.0),
      color.withValues(alpha: 0.7),
      background,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
