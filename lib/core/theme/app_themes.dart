import 'package:flutter/material.dart';
import 'app_palette.dart';

class AppThemePreset {
  final String id;
  final String name;
  final AppPalette palette;
  final bool isPremium;

  const AppThemePreset({
    required this.id,
    required this.name,
    required this.palette,
    this.isPremium = false,
  });

  Color get previewColor => palette.primary;
}

class AppThemes {
  static const defaultDark = AppThemePreset(
    id: 'default_dark',
    name: 'Karanlık',
    isPremium: false,
    palette: AppPalette(
      background: Color(0xFF0A0A0F),
      surface: Color(0xFF13131A),
      surfaceContainer: Color(0xFF1C1C28),
      surfaceContainerHigh: Color(0xFF252535),
      primary: Color(0xFF9B72CF),
      primaryDark: Color(0xFF7B55AF),
      primaryLight: Color(0xFFBB9AEF),
      secondary: Color(0xFFE879F9),
      tertiary: Color(0xFF22D3EE),
      onBackground: Color(0xFFF0F0F5),
      onSurface: Color(0xFFC8C8D5),
      onSurfaceDim: Color(0xFF8E8E9A),
      outline: Color(0xFF3A3A4E),
      outlineVariant: Color(0xFF2A2A3A),
    ),
  );

  static const amoled = AppThemePreset(
    id: 'amoled',
    name: 'AMOLED',
    isPremium: false,
    palette: AppPalette(
      background: Color(0xFF000000),
      surface: Color(0xFF0A0A0A),
      surfaceContainer: Color(0xFF111111),
      surfaceContainerHigh: Color(0xFF1A1A1A),
      primary: Color(0xFF9B72CF),
      primaryDark: Color(0xFF7B55AF),
      primaryLight: Color(0xFFBB9AEF),
      secondary: Color(0xFFE879F9),
      tertiary: Color(0xFF22D3EE),
      onBackground: Color(0xFFF0F0F5),
      onSurface: Color(0xFFC8C8D5),
      onSurfaceDim: Color(0xFF8E8E9A),
      outline: Color(0xFF2A2A2A),
      outlineVariant: Color(0xFF1A1A1A),
    ),
  );

  static const purpleDream = AppThemePreset(
    id: 'purple_dream',
    name: 'Mor Gece',
    isPremium: true,
    palette: AppPalette(
      background: Color(0xFF000000),
      surface: Color(0xFF160E22),
      surfaceContainer: Color(0xFF1E1430),
      surfaceContainerHigh: Color(0xFF271A3D),
      primary: Color(0xFF7C3AED),
      primaryDark: Color(0xFF5B21B6),
      primaryLight: Color(0xFFA78BFA),
      secondary: Color(0xFFC084FC),
      tertiary: Color(0xFF818CF8),
      onBackground: Color(0xFFF5F0FF),
      onSurface: Color(0xFFD4C8F0),
      onSurfaceDim: Color(0xFF9B8EC4),
      outline: Color(0xFF3D2B6B),
      outlineVariant: Color(0xFF2A1C4E),
    ),
  );

  static const sakura = AppThemePreset(
    id: 'sakura',
    name: 'Sakura',
    isPremium: true,
    palette: AppPalette(
      background: Color(0xFF000000),
      surface: Color(0xFF1A0E17),
      surfaceContainer: Color(0xFF241422),
      surfaceContainerHigh: Color(0xFF2E192C),
      primary: Color(0xFFEC4899),
      primaryDark: Color(0xFFBE185D),
      primaryLight: Color(0xFFF9A8D4),
      secondary: Color(0xFFF472B6),
      tertiary: Color(0xFFE879F9),
      onBackground: Color(0xFFFFF0F7),
      onSurface: Color(0xFFEBC8DC),
      onSurfaceDim: Color(0xFFB08090),
      outline: Color(0xFF5C2040),
      outlineVariant: Color(0xFF3D1328),
    ),
  );

  static const forest = AppThemePreset(
    id: 'forest',
    name: 'Orman',
    isPremium: true,
    palette: AppPalette(
      background: Color(0xFF000000),
      surface: Color(0xFF0A1A0E),
      surfaceContainer: Color(0xFF112415),
      surfaceContainerHigh: Color(0xFF172E1C),
      primary: Color(0xFF22C55E),
      primaryDark: Color(0xFF15803D),
      primaryLight: Color(0xFF86EFAC),
      secondary: Color(0xFF4ADE80),
      tertiary: Color(0xFF34D399),
      onBackground: Color(0xFFF0FFF4),
      onSurface: Color(0xFFC8E6D0),
      onSurfaceDim: Color(0xFF7AAB88),
      outline: Color(0xFF1F4D2D),
      outlineVariant: Color(0xFF13321D),
    ),
  );

  static const sunset = AppThemePreset(
    id: 'sunset',
    name: 'Günbatımı',
    isPremium: true,
    palette: AppPalette(
      background: Color(0xFF000000),
      surface: Color(0xFF1C1000),
      surfaceContainer: Color(0xFF271600),
      surfaceContainerHigh: Color(0xFF321C00),
      primary: Color(0xFFF97316),
      primaryDark: Color(0xFFEA580C),
      primaryLight: Color(0xFFFDBA74),
      secondary: Color(0xFFFB923C),
      tertiary: Color(0xFFFBBF24),
      onBackground: Color(0xFFFFF7ED),
      onSurface: Color(0xFFEDD8BF),
      onSurfaceDim: Color(0xFFAD8560),
      outline: Color(0xFF5C2D00),
      outlineVariant: Color(0xFF3D1E00),
    ),
  );

  static const ocean = AppThemePreset(
    id: 'ocean',
    name: 'Okyanus',
    isPremium: true,
    palette: AppPalette(
      background: Color(0xFF000000),
      surface: Color(0xFF06151F),
      surfaceContainer: Color(0xFF0B1E2D),
      surfaceContainerHigh: Color(0xFF10273A),
      primary: Color(0xFF06B6D4),
      primaryDark: Color(0xFF0E7490),
      primaryLight: Color(0xFF67E8F9),
      secondary: Color(0xFF22D3EE),
      tertiary: Color(0xFF38BDF8),
      onBackground: Color(0xFFF0FAFF),
      onSurface: Color(0xFFC0DFF0),
      onSurfaceDim: Color(0xFF6A9DB8),
      outline: Color(0xFF0D3D52),
      outlineVariant: Color(0xFF082838),
    ),
  );

  static const crimson = AppThemePreset(
    id: 'crimson',
    name: 'Kırmızı',
    isPremium: true,
    palette: AppPalette(
      background: Color(0xFF000000),
      surface: Color(0xFF1A0808),
      surfaceContainer: Color(0xFF240C0C),
      surfaceContainerHigh: Color(0xFF2E1010),
      primary: Color(0xFFEF4444),
      primaryDark: Color(0xFFB91C1C),
      primaryLight: Color(0xFFFCA5A5),
      secondary: Color(0xFFF87171),
      tertiary: Color(0xFFFB7185),
      onBackground: Color(0xFFFFF0F0),
      onSurface: Color(0xFFEBC8C8),
      onSurfaceDim: Color(0xFFAB7878),
      outline: Color(0xFF5C1A1A),
      outlineVariant: Color(0xFF3D1010),
    ),
  );

  static const midnight = AppThemePreset(
    id: 'midnight',
    name: 'Gece Mavisi',
    isPremium: true,
    palette: AppPalette(
      background: Color(0xFF000000),
      surface: Color(0xFF060E1E),
      surfaceContainer: Color(0xFF0C1628),
      surfaceContainerHigh: Color(0xFF111E33),
      primary: Color(0xFF3B82F6),
      primaryDark: Color(0xFF1D4ED8),
      primaryLight: Color(0xFF93C5FD),
      secondary: Color(0xFF60A5FA),
      tertiary: Color(0xFF818CF8),
      onBackground: Color(0xFFF0F4FF),
      onSurface: Color(0xFFC8D5F0),
      onSurfaceDim: Color(0xFF7088B0),
      outline: Color(0xFF1A3060),
      outlineVariant: Color(0xFF0F1F42),
    ),
  );

  static const roseGold = AppThemePreset(
    id: 'rose_gold',
    name: 'Gül Altını',
    isPremium: true,
    palette: AppPalette(
      background: Color(0xFF000000),
      surface: Color(0xFF1A1310),
      surfaceContainer: Color(0xFF241C17),
      surfaceContainerHigh: Color(0xFF2E241E),
      primary: Color(0xFFF43F5E),
      primaryDark: Color(0xFFBE123C),
      primaryLight: Color(0xFFFDA4AF),
      secondary: Color(0xFFFB7185),
      tertiary: Color(0xFFF59E0B),
      onBackground: Color(0xFFFFF5F5),
      onSurface: Color(0xFFEDD5D0),
      onSurfaceDim: Color(0xFFAD8880),
      outline: Color(0xFF5C2020),
      outlineVariant: Color(0xFF3D1515),
    ),
  );

  static const List<AppThemePreset> all = [
    defaultDark,
    amoled,
    purpleDream,
    sakura,
    forest,
    sunset,
    ocean,
    crimson,
    midnight,
    roseGold,
  ];

  static AppThemePreset findById(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => defaultDark);
}
