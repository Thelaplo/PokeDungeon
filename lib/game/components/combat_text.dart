import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import '../../models/pokemon_type.dart';

class CombatText extends PositionComponent {
  CombatText({required this.effectiveness, required super.position})
    : super(anchor: Anchor.bottomCenter, priority: _priority);

  static const _priority = 10;
  static const _lifetime = 0.9;
  static const _riseSpeed = 46.0;
  static const _superEffectiveSize = 20.0;
  static const _weakSize = 14.0;
  static const _superEffectiveColor = Color(0xFFFFC93C);
  static const _superEffectiveOutline = Color(0xFFD9480F);
  static const _weakColor = Color(0xFFD0D6D8);
  static const _weakOutline = Color(0xFF08181E);

  final TypeEffectiveness effectiveness;
  final Paint _layerPaint = Paint();
  late final TextPainter _painter;
  double _age = 0;

  bool get _isSuperEffective =>
      effectiveness == TypeEffectiveness.superEffective;

  @override
  Future<void> onLoad() async {
    final outline = _isSuperEffective ? _superEffectiveOutline : _weakOutline;
    _painter = TextPainter(
      text: TextSpan(
        text: effectiveness.label,
        style: TextStyle(
          fontSize: _isSuperEffective ? _superEffectiveSize : _weakSize,
          fontWeight: FontWeight.w900,
          color: _isSuperEffective ? _superEffectiveColor : _weakColor,
          shadows: [
            Shadow(offset: const Offset(0, 2), color: outline),
            Shadow(offset: const Offset(1, 1), color: outline),
            Shadow(offset: const Offset(-1, -1), color: outline),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    size = Vector2(_painter.width, _painter.height);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    position.y -= _riseSpeed * dt;
    if (_age >= _lifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final opacity = (1 - _age / _lifetime).clamp(0.0, 1.0);
    _layerPaint.color = Color.fromRGBO(0, 0, 0, opacity);
    canvas.saveLayer(size.toRect().inflate(4), _layerPaint);
    _painter.paint(canvas, Offset.zero);
    canvas.restore();
  }
}
