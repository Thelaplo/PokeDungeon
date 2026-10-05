import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show EdgeInsets;

class StyledJoystick extends JoystickComponent {
  StyledJoystick()
    : super(
        knob: _ringedCircle(
          radius: _knobRadius,
          fillColor: _knobFillColor,
          ringColor: _knobRingColor,
        ),
        background: _ringedCircle(
          radius: _backgroundRadius,
          fillColor: _backgroundFillColor,
          ringColor: _backgroundRingColor,
        ),
        margin: const EdgeInsets.only(left: 36, bottom: 48),
      );

  static const _knobRadius = 24.0;
  static const _backgroundRadius = 58.0;
  static const _ringWidth = 3.0;
  static const _knobFillColor = Color(0xE65EE6B0);
  static const _knobRingColor = Color(0xFFFFFFFF);
  static const _backgroundFillColor = Color(0x6608181E);
  static const _backgroundRingColor = Color(0xCC3FA7A0);

  static CircleComponent _ringedCircle({
    required double radius,
    required Color fillColor,
    required Color ringColor,
  }) => CircleComponent(
    radius: radius,
    paint: Paint()..color = fillColor,
    children: [
      CircleComponent(
        radius: radius - _ringWidth / 2,
        position: Vector2.all(_ringWidth / 2),
        paint: Paint()
          ..color = ringColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = _ringWidth,
      ),
    ],
  );
}
