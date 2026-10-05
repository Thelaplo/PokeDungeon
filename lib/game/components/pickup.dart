import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../models/item_definition.dart';
import '../dungeon_game.dart';

class Pickup extends PositionComponent with HasGameReference<DungeonGame> {
  Pickup.coins({
    required super.position,
    required this.coinValue,
    required Random random,
  }) : item = null,
       _scatterVelocity = _randomScatter(random),
       super(size: Vector2.all(_coinSide), anchor: Anchor.center);

  Pickup.item({
    required super.position,
    required ItemDefinition this.item,
    required Random random,
  }) : coinValue = 0,
       _scatterVelocity = _randomScatter(random),
       super(size: Vector2.all(_itemSide), anchor: Anchor.center);

  static const _coinSide = 12.0;
  static const _itemSide = 18.0;
  static const _collectDistance = 22.0;
  static const _magnetSpeed = 360.0;
  static const _scatterSpeed = 140.0;
  static const _scatterDamping = 4.0;
  static const _lifetime = 25.0;
  static const _blinkWarning = 5.0;
  static const _blinkPeriod = 0.15;
  static final _coinPaint = Paint()..color = const Color(0xFFFFD040);
  static final _coinShinePaint = Paint()..color = const Color(0xFFFFF4B0);
  static final _outlinePaint = Paint()..color = const Color(0xFF101018);
  static final _ballTopPaint = Paint()..color = const Color(0xFFE83838);
  static final _ballBottomPaint = Paint()..color = const Color(0xFFF8F8F8);

  final ItemDefinition? item;
  final int coinValue;
  final Vector2 _scatterVelocity;
  double _age = 0;
  bool _isCollected = false;
  bool _isAttracted = false;

  static Vector2 _randomScatter(Random random) =>
      Vector2(_scatterSpeed, 0)..rotate(random.nextDouble() * pi * 2);

  void attractToPlayer() => _isAttracted = true;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _lifetime && !_isAttracted) {
      removeFromParent();
      return;
    }
    position.add(_scatterVelocity * dt);
    _scatterVelocity.scale(max(0, 1 - _scatterDamping * dt));
    final area = game.room.playableArea.deflate(size.x);
    position.x = position.x.clamp(area.left, area.right);
    position.y = position.y.clamp(area.top, area.bottom);
    _followPlayer(dt);
  }

  void _followPlayer(double dt) {
    final player = game.player;
    if (_isCollected || player == null || player.isDefeated) {
      return;
    }
    final toPlayer = player.position - position;
    final distance = toPlayer.length;
    if (distance <= _collectDistance) {
      _isCollected = true;
      game.collectPickup(this);
      removeFromParent();
      return;
    }
    if (_isAttracted || distance <= player.stats.magnetRadius) {
      position.add(toPlayer / distance * min(distance, _magnetSpeed * dt));
    }
  }

  @override
  void render(Canvas canvas) {
    final isBlinkHidden =
        _lifetime - _age < _blinkWarning && (_age ~/ _blinkPeriod).isEven;
    if (isBlinkHidden) {
      return;
    }
    if (item == null) {
      _renderCoin(canvas);
    } else {
      _renderBall(canvas);
    }
  }

  void _renderCoin(Canvas canvas) {
    final rect = size.toRect();
    canvas
      ..drawRect(rect, _outlinePaint)
      ..drawRect(rect.deflate(2), _coinPaint)
      ..drawRect(Rect.fromLTWH(3, 3, 3, 3), _coinShinePaint);
  }

  void _renderBall(Canvas canvas) {
    final center = (size / 2).toOffset();
    final radius = size.x / 2;
    final ball = Rect.fromCircle(center: center, radius: radius - 1);
    canvas
      ..drawCircle(center, radius, _outlinePaint)
      ..drawArc(ball, pi, pi, true, _ballTopPaint)
      ..drawArc(ball, 0, pi, true, _ballBottomPaint)
      ..drawRect(Rect.fromLTWH(1, center.dy - 1, size.x - 2, 2), _outlinePaint)
      ..drawCircle(center, 3, _outlinePaint)
      ..drawCircle(center, 1.5, _ballBottomPaint);
  }
}
