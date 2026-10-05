import 'dart:ui';

import 'package:flame/components.dart';

import 'player.dart';

class HeroHealthBar extends PositionComponent with ParentIsA<Player> {
  HeroHealthBar({required super.position})
    : super(size: Vector2(_width, _height), anchor: Anchor.bottomCenter);

  static const _width = 44.0;
  static const _height = 7.0;
  static const _radius = Radius.circular(4);
  static const _highRatio = 0.5;
  static const _mediumRatio = 0.25;
  static final _borderPaint = Paint()..color = const Color(0xFF08181E);
  static final _emptyPaint = Paint()..color = const Color(0xFF0D2129);
  static final _highPaint = Paint()..color = const Color(0xFF5EE6B0);
  static final _mediumPaint = Paint()..color = const Color(0xFFFFC93C);
  static final _lowPaint = Paint()..color = const Color(0xFFFF5A5A);

  @override
  void render(Canvas canvas) {
    final maxHp = parent.stats.maxHp;
    final ratio = maxHp <= 0 ? 0.0 : (parent.hp / maxHp).clamp(0.0, 1.0);
    final outer = RRect.fromRectAndRadius(size.toRect().inflate(1.5), _radius);
    final inner = RRect.fromRectAndRadius(size.toRect(), _radius);
    final filled = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x * ratio, size.y),
      _radius,
    );
    canvas
      ..drawRRect(outer, _borderPaint)
      ..drawRRect(inner, _emptyPaint)
      ..drawRRect(filled, _paintFor(ratio));
  }

  Paint _paintFor(double ratio) {
    if (ratio > _highRatio) {
      return _highPaint;
    }
    if (ratio > _mediumRatio) {
      return _mediumPaint;
    }
    return _lowPaint;
  }
}
