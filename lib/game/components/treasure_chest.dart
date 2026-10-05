import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../dungeon_game.dart';

class TreasureChest extends PositionComponent
    with HasGameReference<DungeonGame> {
  TreasureChest({required this.roomNumber, required super.position})
    : super(size: Vector2(_width, _height), anchor: Anchor.center);

  static const autoOpenDelay = 8.0;
  static const openDistance = 40.0;
  static const _width = 44.0;
  static const _height = 36.0;
  static const _lidHeight = 13.0;
  static const _openDuration = 0.6;
  static const _bounceSpeed = 4.0;
  static const _bounceHeight = 3.0;
  static const _glowSpeed = 3.0;
  static const _glowRadius = 38.0;
  static const _lidOpenLift = 16.0;
  static final _woodPaint = Paint()..color = const Color(0xFF9A5B2B);
  static final _darkWoodPaint = Paint()..color = const Color(0xFF6B3A17);
  static final _trimPaint = Paint()..color = const Color(0xFFFFC93C);
  static final _outlinePaint = Paint()
    ..color = const Color(0xFF08181E)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;
  static final _shadowPaint = Paint()..color = const Color(0x5508181E);

  final int roomNumber;
  final Paint _glowPaint = Paint();
  double _age = 0;
  double _openProgress = 0;
  bool _isOpening = false;

  bool get isOpening => _isOpening;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_isOpening) {
      _advanceOpening(dt);
      return;
    }
    if (_age >= autoOpenDelay || _isPlayerTouching()) {
      _open();
    }
  }

  bool _isPlayerTouching() {
    final player = game.player;
    if (player == null || player.isDefeated) {
      return false;
    }
    return player.position.distanceTo(position) <= openDistance;
  }

  void _open() {
    _isOpening = true;
    game.openChest(this);
  }

  void _advanceOpening(double dt) {
    _openProgress = min(1, _openProgress + dt / _openDuration);
    if (_openProgress >= 1) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final bounce = _isOpening ? 0.0 : sin(_age * _bounceSpeed) * _bounceHeight;
    _renderGlow(canvas);
    canvas.drawOval(Rect.fromLTWH(2, size.y - 6, size.x - 4, 8), _shadowPaint);
    canvas
      ..save()
      ..translate(0, -bounce.abs());
    _renderBody(canvas);
    _renderLid(canvas);
    canvas.restore();
  }

  void _renderGlow(Canvas canvas) {
    final pulse = (sin(_age * _glowSpeed) + 1) / 2;
    final fade = 1 - _openProgress;
    _glowPaint.color = Color.fromRGBO(
      255,
      201,
      60,
      (0.18 + pulse * 0.2) * fade,
    );
    canvas.drawCircle(
      (size / 2).toOffset(),
      _glowRadius * (1 + _openProgress * 0.5),
      _glowPaint,
    );
  }

  void _renderBody(Canvas canvas) {
    final body = Rect.fromLTWH(0, _lidHeight, size.x, size.y - _lidHeight);
    final rounded = RRect.fromRectAndRadius(body, const Radius.circular(4));
    canvas
      ..drawRRect(rounded, _woodPaint)
      ..drawRect(
        Rect.fromLTWH(0, body.top + body.height * 0.55, size.x, 3),
        _darkWoodPaint,
      )
      ..drawRect(Rect.fromLTWH(size.x / 2 - 4, body.top + 2, 8, 9), _trimPaint)
      ..drawRRect(rounded, _outlinePaint);
  }

  void _renderLid(Canvas canvas) {
    final lift = _openProgress * _lidOpenLift;
    final lid = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, -lift, size.x, _lidHeight + 1),
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
    );
    canvas
      ..drawRRect(lid, _darkWoodPaint)
      ..drawRect(Rect.fromLTWH(0, _lidHeight - 3 - lift, size.x, 3), _trimPaint)
      ..drawRRect(lid, _outlinePaint);
  }
}
