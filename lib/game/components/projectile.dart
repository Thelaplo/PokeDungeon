import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../dungeon_game.dart';
import 'enemy.dart';

class Projectile extends PositionComponent
    with HasGameReference<DungeonGame>, CollisionCallbacks {
  Projectile({
    required super.position,
    required Vector2 direction,
    required this.damage,
    required Color color,
    this.piercing = 0,
    this.canChain = false,
    this.appliesBurn = false,
    Enemy? ignoredEnemy,
  }) : _velocity = direction.normalized() * _speed,
       _paint = Paint()..color = color,
       super(size: Vector2.all(_side), anchor: Anchor.center) {
    if (ignoredEnemy != null) {
      _ignoredEnemies.add(ignoredEnemy);
    }
  }

  static const _speed = 420.0;
  static const _side = 10.0;
  static const _lifetime = 1.6;
  static final _corePaint = Paint()..color = const Color(0xFFFFFFFF);

  final int damage;
  final int piercing;
  final bool canChain;
  final bool appliesBurn;
  final Set<Enemy> _ignoredEnemies = {};
  final Set<Enemy> _hitEnemies = {};
  final Vector2 _velocity;
  final Paint _paint;
  double _age = 0;

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    position.add(_velocity * dt);
    final isOutOfRoom = !game.room.playableArea.contains(position.toOffset());
    if (_age >= _lifetime || isOutOfRoom) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (isRemoving ||
        other is! Enemy ||
        other.isDefeated ||
        _ignoredEnemies.contains(other) ||
        !_hitEnemies.add(other)) {
      return;
    }
    _hit(other);
    if (_hitEnemies.length > piercing) {
      removeFromParent();
    }
  }

  void _hit(Enemy enemy) {
    enemy.takeHeroHit(damage);
    if (appliesBurn && !enemy.isDefeated) {
      enemy.ignite(damage);
    }
    if (canChain) {
      game.spawnChainBounce(source: enemy, hitDamage: damage);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas
      ..drawRect(size.toRect(), _paint)
      ..drawRect(size.toRect().deflate(_side / 4), _corePaint);
  }
}
