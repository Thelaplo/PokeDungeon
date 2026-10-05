import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import '../../models/enemy_rank.dart';
import '../../models/monster_data.dart';
import '../../models/pokemon_type.dart';
import '../combat/cooldown_gate.dart';
import '../combat/type_damage.dart';
import '../dungeon_game.dart';
import '../heroes/burn_status.dart';
import 'combat_text.dart';
import 'health_bar.dart';
import 'player.dart';

class Enemy extends SpriteComponent
    with HasGameReference<DungeonGame>, CollisionCallbacks {
  Enemy({
    required this.data,
    required Image spriteImage,
    required super.position,
    required double hpMultiplier,
    this.rank = EnemyRank.normal,
    this.contactDamageMultiplier = 1,
    this.isFinalBoss = false,
  }) : maxHp = max(1, (data.baseHp * hpMultiplier).round()),
       super(
         sprite: Sprite(spriteImage),
         size: Vector2.all(
           rank.side * (isFinalBoss ? _finalBossSideMultiplier : 1),
         ),
         anchor: Anchor.center,
       );

  static const _hitboxRatio = 0.3;
  static const _separationRadius = 44.0;
  static const _separationStrength = 60.0;
  static const _flashDuration = 0.08;
  static const _deathDuration = 0.2;
  static const _attackToDamageRatio = 8;
  static const _minContactDamage = 3;
  static const _maxContactDamage = 20;
  static const _finalBossSideMultiplier = 1.3;
  static const _combatTextInterval = 0.6;
  static const _combatTextLift = 0.35;
  static const _flashFilter = ColorFilter.mode(
    Color(0xFFFFFFFF),
    BlendMode.srcATop,
  );
  static const _burnFilter = ColorFilter.mode(
    Color(0x88FF7A2A),
    BlendMode.srcATop,
  );

  final MonsterData data;
  final EnemyRank rank;
  final double contactDamageMultiplier;
  final bool isFinalBoss;
  final int maxHp;
  late int hp = maxHp;
  bool isDefeated = false;
  double _flashTimer = 0;
  final BurnStatus _burn = BurnStatus();
  final CooldownGate _combatTextGate = CooldownGate(
    interval: _combatTextInterval,
  );
  late final List<PokemonType> types = TypeDamage.parseTypes(data.types);
  late final double heroAttackMultiplier = TypeDamage.heroAttackMultiplier(
    heroType: game.hero.type,
    enemyTypes: types,
  );
  late final double _contactTypeMultiplier = TypeDamage.enemyContactMultiplier(
    enemyTypes: types,
    heroType: game.hero.type,
  );

  bool get isBoss => rank.isBoss;

  bool get isBurning => _burn.isBurning;

  double get hpRatio => hp / maxHp;

  int get scoreValue => maxHp * rank.scoreMultiplier;

  int get contactDamage {
    final baseDamage = (data.attack / _attackToDamageRatio).round().clamp(
      _minContactDamage,
      _maxContactDamage,
    );
    return max(
      1,
      (baseDamage *
              rank.damageMultiplier *
              contactDamageMultiplier *
              _contactTypeMultiplier)
          .round(),
    );
  }

  @override
  Future<void> onLoad() async {
    paint.filterQuality = FilterQuality.none;
    add(
      CircleHitbox(
        radius: size.x * _hitboxRatio,
        position: size / 2,
        anchor: Anchor.center,
      ),
    );
    add(
      HealthBar(
        hpRatio: () => hpRatio,
        size: Vector2(size.x * 0.5, 5),
        position: Vector2(size.x / 2, size.y * 0.15),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateFlash(dt);
    _combatTextGate.tick(dt);
    _updateBurn(dt);
    final player = game.player;
    if (isDefeated || player == null || player.isDefeated) {
      return;
    }
    final toPlayer = player.position - position;
    if (toPlayer.length2 > 1) {
      position.add(toPlayer.normalized() * data.speed * dt);
    }
    _separateFromOtherEnemies(dt);
    final area = game.room.playableArea;
    final halfSide = size.x * _hitboxRatio;
    position.x = position.x.clamp(area.left + halfSide, area.right - halfSide);
    position.y = position.y.clamp(area.top + halfSide, area.bottom - halfSide);
  }

  void _separateFromOtherEnemies(double dt) {
    final push = Vector2.zero();
    for (final other in game.world.children.whereType<Enemy>()) {
      if (identical(other, this) || other.isDefeated) {
        continue;
      }
      final away = position - other.position;
      final distance = away.length;
      if (distance > 0 && distance < _separationRadius) {
        push.add(away / distance * (_separationRadius - distance));
      }
    }
    if (!push.isZero()) {
      position.add(push.normalized() * _separationStrength * dt);
    }
  }

  void _updateFlash(double dt) {
    if (_flashTimer <= 0) {
      return;
    }
    _flashTimer -= dt;
    if (_flashTimer <= 0) {
      _refreshTint();
    }
  }

  void _updateBurn(double dt) {
    if (isDefeated || !_burn.isBurning) {
      return;
    }
    final burnDamage = _burn.tick(dt);
    if (burnDamage > 0) {
      _receiveDamage(
        TypeDamage.scale(burnDamage, heroAttackMultiplier),
        isDirectHit: false,
      );
    }
    if (!_burn.isBurning) {
      _refreshTint();
    }
  }

  void _refreshTint() {
    if (_flashTimer > 0) {
      paint.colorFilter = _flashFilter;
      return;
    }
    paint.colorFilter = _burn.isBurning ? _burnFilter : null;
  }

  void ignite(int hitDamage) {
    if (isDefeated) {
      return;
    }
    _burn.ignite(hitDamage);
    _refreshTint();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (!isDefeated && other is Player) {
      other.takeContactDamage(contactDamage);
    }
  }

  void takeHeroHit(int baseDamage) {
    if (isDefeated) {
      return;
    }
    _showEffectiveness();
    takeDamage(TypeDamage.scale(baseDamage, heroAttackMultiplier));
  }

  void _showEffectiveness() {
    final effectiveness = TypeChart.effectivenessOf(heroAttackMultiplier);
    if (effectiveness == TypeEffectiveness.neutral) {
      return;
    }
    if (!_combatTextGate.tryPass()) {
      return;
    }
    game.world.add(
      CombatText(
        effectiveness: effectiveness,
        position: Vector2(position.x, position.y - size.y * _combatTextLift),
      ),
    );
  }

  void takeDamage(int damage) => _receiveDamage(damage, isDirectHit: true);

  void _receiveDamage(int damage, {required bool isDirectHit}) {
    if (isDefeated) {
      return;
    }
    hp = max(0, hp - damage);
    if (isDirectHit) {
      _flashTimer = _flashDuration;
    }
    _refreshTint();
    game.onEnemyDamaged(this, isDirectHit: isDirectHit);
    if (hp > 0) {
      return;
    }
    isDefeated = true;
    game.onEnemyDefeated(this);
    add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: _deathDuration),
        onComplete: removeFromParent,
      ),
    );
  }
}
