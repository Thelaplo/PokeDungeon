import 'package:flutter/material.dart';

import 'ball_style.dart';
import 'poke_ball_painter.dart';

class PokeBallIcon extends StatelessWidget {
  const PokeBallIcon({
    required this.size,
    this.style = BallStyle.pokeBall,
    super.key,
  });

  final double size;
  final BallStyle style;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: PokeBallPainter(style: style)),
      ),
    );
  }
}
