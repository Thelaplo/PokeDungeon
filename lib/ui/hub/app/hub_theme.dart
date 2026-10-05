import 'package:flutter/material.dart';

import '../hub_style.dart';

abstract final class HubTheme {
  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: HubStyle.backgroundBottom,
    colorScheme: const ColorScheme.dark(
      primary: HubStyle.accent,
      secondary: HubStyle.gem,
      surface: HubStyle.panelBottom,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: HubStyle.accent,
    ),
    tooltipTheme: TooltipThemeData(
      textStyle: HubStyle.body(fontSize: 12, color: HubStyle.white),
      decoration: BoxDecoration(
        color: HubStyle.deepNavy,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
