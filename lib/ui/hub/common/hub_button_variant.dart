import 'package:flutter/material.dart';

enum HubButtonVariant {
  primary(
    gradientColors: [Color(0xFFFF8A75), Color(0xFFF2554A), Color(0xFFD93A3A)],
    lipColor: Color(0xFF8E1D22),
    labelColor: Color(0xFFFFFFFF),
    hasOutlinedLabel: true,
  ),
  secondary(
    gradientColors: [Color(0xFF5EE6B0), Color(0xFF22B783)],
    lipColor: Color(0xFF136B4C),
    labelColor: Color(0xFFFFFFFF),
    hasOutlinedLabel: true,
  ),
  info(
    gradientColors: [Color(0xFF7FD6FF), Color(0xFF2F8FE0)],
    lipColor: Color(0xFF1D4BA8),
    labelColor: Color(0xFFFFFFFF),
    hasOutlinedLabel: true,
  ),
  disabled(
    gradientColors: [Color(0xFF5F7378), Color(0xFF475A5F)],
    lipColor: Color(0xFF2E3D41),
    labelColor: Color(0xFFE1E8EA),
    hasOutlinedLabel: false,
  );

  const HubButtonVariant({
    required this.gradientColors,
    required this.lipColor,
    required this.labelColor,
    required this.hasOutlinedLabel,
  });

  final List<Color> gradientColors;
  final Color lipColor;
  final Color labelColor;
  final bool hasOutlinedLabel;

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: gradientColors,
  );
}
