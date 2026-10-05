import 'package:flutter/material.dart';

enum BallStyle {
  pokeBall(
    topColor: Color(0xFFF2443A),
    topShade: Color(0xFFB8231C),
    hasHyperStripes: false,
  ),
  hyperBall(
    topColor: Color(0xFF3A3F4A),
    topShade: Color(0xFF16181E),
    hasHyperStripes: true,
  );

  const BallStyle({
    required this.topColor,
    required this.topShade,
    required this.hasHyperStripes,
  });

  final Color topColor;
  final Color topShade;
  final bool hasHyperStripes;
}
