import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_palette.dart';

class AppTheme {
  static ThemeData from(AppPalette p) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: p.background,
      extensions: [p],
      colorScheme: ColorScheme.dark(
        brightness: Brightness.dark,
        primary: p.primary,
        onPrimary: Colors.white,
        primaryContainer: p.primaryDark,
        onPrimaryContainer: p.primaryLight,
        secondary: p.secondary,
        onSecondary: Colors.white,
        tertiary: p.tertiary,
        error: p.error,
        surface: p.surface,
        onSurface: p.onSurface,
        surfaceContainerHighest: p.surfaceContainerHigh,
        outline: p.outline,
        outlineVariant: p.outlineVariant,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.onBackground,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: p.onBackground,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.primary.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: p.primary);
          }
          return IconThemeData(color: p.onSurfaceDim);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: p.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(color: p.onSurfaceDim, fontSize: 11);
        }),
      ),
      cardTheme: CardThemeData(
        color: p.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.error),
        ),
        hintStyle: TextStyle(color: p.onSurfaceDim),
        labelStyle: TextStyle(color: p.onSurfaceDim),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          side: BorderSide(color: p.primary),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceContainer,
        selectedColor: p.primary.withValues(alpha: 0.3),
        labelStyle: TextStyle(color: p.onSurface, fontSize: 12),
        side: BorderSide(color: p.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      dividerTheme: DividerThemeData(color: p.outlineVariant, thickness: 1),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: p.onBackground,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          color: p.onBackground,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
            color: p.onBackground, fontSize: 22, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(
            color: p.onBackground, fontSize: 18, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(
            color: p.onBackground, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge:
            TextStyle(color: p.onSurface, fontSize: 15, height: 1.5),
        bodyMedium:
            TextStyle(color: p.onSurface, fontSize: 14, height: 1.4),
        bodySmall: TextStyle(color: p.onSurfaceDim, fontSize: 12),
        labelLarge: TextStyle(
            color: p.onSurface, fontSize: 13, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: p.onSurfaceDim, fontSize: 11),
      ),
    );
  }
}
