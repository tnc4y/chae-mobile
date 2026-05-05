import 'package:flutter/material.dart';
import 'app_palette.dart';
import 'app_themes.dart';

extension ContextColors on BuildContext {
  AppPalette get colors =>
      Theme.of(this).extension<AppPalette>() ?? AppThemes.defaultDark.palette;
}
