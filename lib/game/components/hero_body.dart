import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../services/poke_api_service.dart';
import '../dungeon_game.dart';
import 'player.dart';
import 'trainer_pixel_art.dart';

class HeroBody extends PositionComponent
    with ParentIsA<Player>, HasGameReference<DungeonGame> {
  HeroBody({required super.size});

  static const _ringCenterRatio = 0.86;
  static const _ringWidthRatio = 0.8;
  static const _ringHeightRatio = 0.22;
  static const _ringFillAlpha = 0.35;
  static const _ringStrokeAlpha = 0.9;
  static const _shieldRadiusRatio = 0.62;
  static final _shieldFillPaint = Paint()..color = const Color(0x404AB8FF);
  static final _shieldStrokePaint = Paint()
    ..color = const Color(0xCC7FD6FF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;

  final Paint _spritePaint = Paint()..filterQuality = FilterQuality.none;
  final Paint _ringFillPaint = Paint();
  final Paint _ringStrokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  Image? _sprite;

  @override
  Future<void> onLoad() async {
    final accentColor = parent.hero.accentColor;
    _ringFillPaint.color = accentColor.withValues(alpha: _ringFillAlpha);
    _ringStrokePaint.color = accentColor.withValues(alpha: _ringStrokeAlpha);
    final spriteUrl = parent.hero.spriteUrl;
    if (spriteUrl != null) {
      unawaited(_loadSprite(spriteUrl));
    }
  }

  Future<void> _loadSprite(String spriteUrl) async {
    try {
      _sprite = await game.loadMonsterSprite(spriteUrl);
    } on PokeApiException {
      _sprite = null;
    }
  }

  @override
  void render(Canvas canvas) {
    if (!parent.hero.isTrainer) {
      _renderRing(canvas);
    }
    if (!parent.isBlinkHidden) {
      _renderHero(canvas);
    }
    if (parent.isShieldActive) {
      _renderShield(canvas);
    }
  }

  void _renderRing(Canvas canvas) {
    final ring = Rect.fromCenter(
      center: Offset(size.x / 2, size.y * _ringCenterRatio),
      width: size.x * _ringWidthRatio,
      height: size.y * _ringHeightRatio,
    );
    canvas
      ..drawOval(ring, _ringFillPaint)
      ..drawOval(ring, _ringStrokePaint);
  }

  void _renderHero(Canvas canvas) {
    final sprite = _sprite;
    if (sprite == null) {
      _renderTrainer(canvas);
      return;
    }
    canvas.save();
    if (!parent.isFacingLeft) {
      canvas
        ..translate(size.x, 0)
        ..scale(-1, 1);
    }
    canvas
      ..drawImageRect(
        sprite,
        Rect.fromLTWH(0, 0, sprite.width.toDouble(), sprite.height.toDouble()),
        size.toRect(),
        _spritePaint,
      )
      ..restore();
  }

  void _renderTrainer(Canvas canvas) {
    canvas
      ..save()
      ..translate(
        (size.x - TrainerPixelArt.width) / 2,
        (size.y - TrainerPixelArt.height) / 2,
      );
    TrainerPixelArt.render(canvas, isFacingLeft: parent.isFacingLeft);
    canvas.restore();
  }

  void _renderShield(Canvas canvas) {
    final center = (size / 2).toOffset();
    final radius = size.x * _shieldRadiusRatio;
    canvas
      ..drawCircle(center, radius, _shieldFillPaint)
      ..drawCircle(center, radius, _shieldStrokePaint);
  }
}
