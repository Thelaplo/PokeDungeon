import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../models/active_boost.dart';
import '../../models/hero_definition.dart';
import '../../models/item_definition.dart';
import '../../models/player_stats.dart';
import '../dungeon_game.dart';
import '../heroes/hero_ability_rules.dart';
import '../heroes/shield_charge.dart';
import 'enemy.dart';
import 'hero_body.dart';
import 'hero_health_bar.dart';
import 'projectile.dart';
import 'trainer_pixel_art.dart';

class Player extends PositionComponent
    with HasGameReference<DungeonGame>, KeyboardHandler, CollisionCallbacks {
  Player({required this.joystick, required this.hero})
    : shield = HeroAbilityRules.hasShield(hero.ability) ? ShieldCharge() : null,
      super(size: _sizeFor(hero), anchor: Anchor.center);

  static const _pokemonHeroSide = 56.0;
  static const _healthBarGap = 4.0;

  static const _invulnerabilityDuration = 1.0;
  static const _blinkPeriod = 0.1;
  static const _spreadAngle = 0.2;
  static final _movementKeys = {
    LogicalKeyboardKey.keyW: (0.0, -1.0),
    LogicalKeyboardKey.keyZ: (0.0, -1.0),
    LogicalKeyboardKey.arrowUp: (0.0, -1.0),
    LogicalKeyboardKey.keyS: (0.0, 1.0),
    LogicalKeyboardKey.arrowDown: (0.0, 1.0),
    LogicalKeyboardKey.keyA: (-1.0, 0.0),
    LogicalKeyboardKey.keyQ: (-1.0, 0.0),
    LogicalKeyboardKey.arrowLeft: (-1.0, 0.0),
    LogicalKeyboardKey.keyD: (1.0, 0.0),
    LogicalKeyboardKey.arrowRight: (1.0, 0.0),
  };
  static final _inventoryKeys = {
    LogicalKeyboardKey.keyI,
    LogicalKeyboardKey.tab,
    LogicalKeyboardKey.escape,
  };
  static const _pauseKey = LogicalKeyboardKey.keyP;

  final JoystickComponent joystick;
  final HeroDefinition hero;
  final ShieldCharge? shield;
  final Vector2 _keyboardDirection = Vector2.zero();
  final Vector2 _aimDirection = Vector2(0, -1);
  final List<ActiveBoost> _boosts = [];
  PlayerStats _stats = PlayerStats.from(const []);
  bool _isFiringByKeyboard = false;
  bool _isShotQueued = false;
  bool _isMoving = false;
  bool _isFacingLeft = false;
  double _fireTimer = 0;
  double _invulnerabilityTimer = 0;
  double _pendingRegen = 0;
  late int hp = _stats.maxHp;

  PlayerStats get stats => _stats;

  bool get isInvulnerable => _invulnerabilityTimer > 0;

  bool get isDefeated => hp <= 0;

  bool get isFacingLeft => _isFacingLeft;

  bool get isShieldActive => shield?.isActive ?? false;

  bool get isBlinkHidden =>
      isInvulnerable && (_invulnerabilityTimer ~/ _blinkPeriod).isEven;

  static Vector2 _sizeFor(HeroDefinition hero) => hero.isTrainer
      ? Vector2(TrainerPixelArt.width, TrainerPixelArt.height)
      : Vector2.all(_pokemonHeroSide);

  @override
  Future<void> onLoad() async {
    add(
      RectangleHitbox(
        size: Vector2(size.x * 0.6, size.y * 0.8),
        position: Vector2(size.x * 0.2, size.y * 0.15),
      ),
    );
    add(HeroBody(size: size.clone()));
    add(HeroHealthBar(position: Vector2(size.x / 2, -_healthBarGap)));
  }

  @override
  void onMount() {
    super.onMount();
    game.inventory.addListener(_refreshStats);
    game.skills.addListener(_refreshStats);
    _refreshStats();
  }

  @override
  void onRemove() {
    game.inventory.removeListener(_refreshStats);
    game.skills.removeListener(_refreshStats);
    super.onRemove();
  }

  void stopFiring() {
    _isFiringByKeyboard = false;
    _isShotQueued = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDefeated) {
      return;
    }
    _invulnerabilityTimer = max(0, _invulnerabilityTimer - dt);
    shield?.tick(dt);
    _fireTimer -= dt;
    _tickBoosts(dt);
    _regenerate(dt);
    _move(dt);
    if (_fireTimer <= 0) {
      _tryFire();
    }
  }

  void _refreshStats() {
    final previousMaxHp = _stats.maxHp;
    _stats = PlayerStats.from([
      ...game.inventory.equipmentModifiers,
      hero.modifiers,
      ...game.skills.modifiers,
      for (final boost in _boosts) ?boost.item.boost,
    ]);
    final maxHpGain = _stats.maxHp - previousMaxHp;
    hp = (hp + max(0, maxHpGain))
        .clamp(isDefeated ? 0 : 1, _stats.maxHp)
        .toInt();
    game
      ..playerMaxHp.value = _stats.maxHp
      ..playerHp.value = hp;
    _publishBoosts();
  }

  void _tickBoosts(double dt) {
    if (_boosts.isEmpty) {
      return;
    }
    final displayedBefore = _boosts
        .map((boost) => boost.displayedSeconds)
        .toList();
    for (final boost in _boosts) {
      boost.remainingSeconds -= dt;
    }
    final hasExpired = _boosts.any((boost) => boost.isExpired);
    _boosts.removeWhere((boost) => boost.isExpired);
    if (hasExpired) {
      _refreshStats();
      return;
    }
    final displayedAfter = _boosts.map((boost) => boost.displayedSeconds);
    if (!listEquals(displayedBefore, displayedAfter.toList())) {
      _publishBoosts();
    }
  }

  void _publishBoosts() {
    game.activeBoosts.value = [
      for (final boost in _boosts)
        (name: boost.item.name, secondsLeft: boost.displayedSeconds),
    ];
  }

  void _regenerate(double dt) {
    if (_stats.regenPerSecond <= 0 || hp >= _stats.maxHp) {
      _pendingRegen = 0;
      return;
    }
    _pendingRegen += _stats.regenPerSecond * dt;
    final wholePoints = _pendingRegen.floor();
    if (wholePoints > 0) {
      _pendingRegen -= wholePoints;
      heal(wholePoints);
    }
  }

  void _move(double dt) {
    final direction = joystick.delta.isZero()
        ? _keyboardDirection.normalized()
        : joystick.relativeDelta;
    _isMoving = !direction.isZero();
    if (!_isMoving) {
      return;
    }
    position.add(direction * _stats.speed * dt);
    _aimDirection.setFrom(direction.normalized());
    if (direction.x != 0) {
      _isFacingLeft = direction.x < 0;
    }
    final area = game.room.playableArea;
    position.x = position.x.clamp(
      area.left + size.x / 2,
      area.right - size.x / 2,
    );
    position.y = position.y.clamp(
      area.top + size.y / 2,
      area.bottom - size.y / 2,
    );
  }

  void _tryFire() {
    final target = _nearestEnemy();
    final isManualShot = _isFiringByKeyboard || _isShotQueued;
    final isAutoShot = !_isMoving && target != null;
    if (!isManualShot && !isAutoShot) {
      return;
    }
    _isShotQueued = false;
    final aim = target == null
        ? _aimDirection.clone()
        : (target.position - position).normalized();
    if (aim.isZero()) {
      return;
    }
    _fireTimer = _stats.fireCooldown;
    _fireVolley(aim);
  }

  void _fireVolley(Vector2 aim) {
    final projectileCount = _stats.projectileCount;
    for (var index = 0; index < projectileCount; index++) {
      _spawnProjectile(aim, (index - (projectileCount - 1) / 2) * _spreadAngle);
    }
    for (var pair = 1; pair <= _stats.diagonalShotPairs; pair++) {
      final angle = pi / 4 / pair;
      _spawnProjectile(aim, angle);
      _spawnProjectile(aim, -angle);
    }
    for (var index = 0; index < _stats.rearShots; index++) {
      _spawnProjectile(
        aim,
        pi + (index - (_stats.rearShots - 1) / 2) * _spreadAngle,
      );
    }
  }

  void _spawnProjectile(Vector2 aim, double angleOffset) {
    game.world.add(
      Projectile(
        position: position.clone(),
        direction: aim.clone()..rotate(angleOffset),
        damage: _stats.damage,
        piercing: HeroAbilityRules.projectilePiercing(
          hero.ability,
          _stats.piercing,
        ),
        color: game.projectileColor,
        canChain: HeroAbilityRules.canChain(hero.ability),
        appliesBurn: HeroAbilityRules.appliesBurn(hero.ability),
      ),
    );
  }

  Enemy? _nearestEnemy() {
    Enemy? nearestEnemy;
    var nearestDistance = double.infinity;
    for (final enemy in game.world.children.whereType<Enemy>()) {
      if (enemy.isDefeated) {
        continue;
      }
      final distance = enemy.position.distanceToSquared(position);
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestEnemy = enemy;
      }
    }
    return nearestEnemy;
  }

  void takeContactDamage(int damage) {
    if (isInvulnerable || isDefeated) {
      return;
    }
    if (shield?.tryAbsorb() ?? false) {
      _invulnerabilityTimer = _invulnerabilityDuration;
      return;
    }
    hp = (hp - _stats.reduceIncomingDamage(damage)).clamp(0, _stats.maxHp);
    _invulnerabilityTimer = _invulnerabilityDuration;
    game.playerHp.value = hp;
    if (isDefeated) {
      game.onPlayerDefeated();
    }
  }

  void heal(int amount) {
    if (isDefeated || amount <= 0) {
      return;
    }
    hp = min(_stats.maxHp, hp + amount);
    game.playerHp.value = hp;
  }

  void onEnemyHit() => heal(_stats.healOnHit);

  void applyConsumable(ConsumableItem item) {
    heal(item.healAmount);
    if (item.boost == null) {
      return;
    }
    _boosts
      ..removeWhere((boost) => boost.item == item)
      ..add(ActiveBoost(item: item));
    _refreshStats();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent && _inventoryKeys.contains(event.logicalKey)) {
      game.openInventory();
      return false;
    }
    if (event is KeyDownEvent && event.logicalKey == _pauseKey) {
      game.openPauseMenu();
      return false;
    }
    _keyboardDirection.setZero();
    for (final key in keysPressed) {
      final axis = _movementKeys[key];
      if (axis != null) {
        _keyboardDirection.add(Vector2(axis.$1, axis.$2));
      }
    }
    final isSpacePressed = keysPressed.contains(LogicalKeyboardKey.space);
    if (isSpacePressed && !_isFiringByKeyboard) {
      _isShotQueued = true;
    }
    _isFiringByKeyboard = isSpacePressed;
    return true;
  }
}
