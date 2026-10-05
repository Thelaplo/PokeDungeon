import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../hub_style.dart';
import 'ball_style.dart';

class PokeBallPainter extends CustomPainter {
  const PokeBallPainter({this.style = BallStyle.pokeBall});

  static const _bottomColor = Color(0xFFF4F6FB);
  static const _bottomShade = Color(0xFFC8CEDD);
  static const _hyperStripeColor = Color(0xFFFFD23F);
  static const _bandRatio = 0.12;
  static const _buttonRatio = 0.28;
  static const _ballRatio = 0.94;

  final BallStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final ballRect = Rect.fromCircle(
      center: center,
      radius: radius * _ballRatio,
    );
    canvas
      ..drawCircle(center, radius, Paint()..color = HubStyle.navy)
      ..drawArc(
        ballRect,
        math.pi,
        math.pi,
        true,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [style.topColor, style.topShade],
          ).createShader(ballRect),
      )
      ..drawArc(
        ballRect,
        0,
        math.pi,
        true,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bottomColor, _bottomShade],
          ).createShader(ballRect),
      );
    if (style.hasHyperStripes) {
      _paintHyperStripes(canvas, center, radius);
    }
    canvas
      ..drawRect(
        Rect.fromCenter(
          center: center,
          width: radius * 2,
          height: radius * _bandRatio,
        ),
        Paint()..color = HubStyle.navy,
      )
      ..drawCircle(
        center,
        radius * _buttonRatio,
        Paint()..color = HubStyle.navy,
      )
      ..drawCircle(
        center,
        radius * _buttonRatio * 0.68,
        Paint()..color = _bottomColor,
      )
      ..drawCircle(
        center.translate(-radius * 0.42, -radius * 0.5),
        radius * 0.13,
        Paint()..color = HubStyle.white.withValues(alpha: 0.7),
      );
  }

  void _paintHyperStripes(Canvas canvas, Offset center, double radius) {
    final stripePaint = Paint()..color = _hyperStripeColor;
    for (final side in const [-1.0, 1.0]) {
      final stripe = Path()
        ..moveTo(center.dx + side * radius * 0.22, center.dy - radius * 0.86)
        ..lineTo(center.dx + side * radius * 0.5, center.dy - radius * 0.72)
        ..lineTo(center.dx + side * radius * 0.36, center.dy - radius * 0.1)
        ..lineTo(center.dx + side * radius * 0.18, center.dy - radius * 0.1)
        ..close();
      canvas.drawPath(stripe, stripePaint);
    }
  }

  @override
  bool shouldRepaint(PokeBallPainter oldDelegate) => oldDelegate.style != style;
}
