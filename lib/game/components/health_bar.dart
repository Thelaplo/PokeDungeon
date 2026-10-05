import 'dart:ui';

import 'package:flame/components.dart';

class HealthBar extends PositionComponent {
  HealthBar({
    required this.hpRatio,
    required super.size,
    required super.position,
  }) : super(anchor: Anchor.bottomCenter);

  final double Function() hpRatio;

  static final _borderPaint = Paint()..color = const Color(0xFF101018);
  static final _emptyPaint = Paint()..color = const Color(0xFF3A1010);
  static final _highPaint = Paint()..color = const Color(0xFF40E060);
  static final _mediumPaint = Paint()..color = const Color(0xFFF0C030);
  static final _lowPaint = Paint()..color = const Color(0xFFF04030);

  @override
  void render(Canvas canvas) {
    final ratio = hpRatio().clamp(0.0, 1.0);
    canvas
      ..drawRect(size.toRect().inflate(1), _borderPaint)
      ..drawRect(size.toRect(), _emptyPaint)
      ..drawRect(Rect.fromLTWH(0, 0, size.x * ratio, size.y), _paintFor(ratio));
  }

  Paint _paintFor(double ratio) {
    if (ratio > 0.5) {
      return _highPaint;
    }
    if (ratio > 0.2) {
      return _mediumPaint;
    }
    return _lowPaint;
  }
}
