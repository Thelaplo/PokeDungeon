import 'dart:math' show Random, max, min;
import 'dart:ui';

import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart' show HasKeyboardHandlerComponents;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show decodeImageFromList;

import '../models/boss_status.dart';
import '../models/chapter.dart';
import '../models/enemy_rank.dart';
import '../models/hero_definition.dart';
import '../models/item_definition.dart';
import '../models/pokemon_type.dart';
import '../models/room_theme.dart';
import '../models/run_config.dart';
import '../models/run_result.dart';
import '../models/skill_definition.dart';
import '../services/poke_api_service.dart';
import 'chests/chest_loot.dart';
import 'chests/chest_reward.dart';
import 'chests/chest_schedule.dart';
import 'components/dungeon_room.dart';
import 'components/enemy.dart';
import 'components/pickup.dart';
import 'components/player.dart';
import 'components/projectile.dart';
import 'components/styled_joystick.dart';
import 'components/treasure_chest.dart';
import 'frame_steps.dart';
import 'heroes/hero_ability_rules.dart';
import 'items/inventory.dart';
import 'items/loot_table.dart';
import 'room_director.dart';
import 'run_tracker.dart';
import 'skills/run_skills.dart';

typedef BoostStatus = ({String name, int secondsLeft});

class DungeonGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  DungeonGame({
    required this.config,
    required this.api,
    Random? random,
    DateTime Function()? clock,
  }) : _random = random ?? Random(),
       _today = (clock ?? DateTime.now)(),
       inventory = Inventory(
         loadout: config.loadout,
         startingConsumables: config.startingConsumables,
       ),
       skills = RunSkills(),
       tracker = RunTracker(chapterNumber: config.chapter.number) {
    _lootTable = LootTable(random: _random);
    _chestLoot = ChestLoot(random: _random);
  }

  static const hudOverlay = 'hud';
  static const inventoryOverlay = 'inventory';
  static const skillChoiceOverlay = 'skillChoice';
  static const pauseOverlay = 'pause';
  static const runSummaryOverlay = 'runSummary';
  static const _blockingOverlays = [
    inventoryOverlay,
    skillChoiceOverlay,
    pauseOverlay,
    runSummaryOverlay,
  ];
  static const _skillChoiceDelay = 0.9;
  static const _victoryMaxDelay = 3.0;
  static const _roomSize = 1100.0;
  static const _visibleWorldExtent = 560.0;
  static const _maxZoom = 3.0;
  static const _toastDuration = 2.2;
  static const _maxCoinPickupsPerEnemy = 4;
  static const _afterChestDelay = 1.2;

  final RunConfig config;
  final PokeApiService api;
  final Inventory inventory;
  final RunSkills skills;
  final RunTracker tracker;
  final Random _random;
  final DateTime _today;
  late final LootTable _lootTable;
  late final ChestLoot _chestLoot;
  TreasureChest? _pendingChest;
  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> coins = ValueNotifier(0);
  final ValueNotifier<int> roomNumber = ValueNotifier(0);
  final ValueNotifier<int> playerHp = ValueNotifier(0);
  final ValueNotifier<int> playerMaxHp = ValueNotifier(1);
  final ValueNotifier<List<BoostStatus>> activeBoosts = ValueNotifier(const []);
  final ValueNotifier<RoomTheme> roomTheme = ValueNotifier(RoomTheme.crypt);
  final ValueNotifier<BossStatus?> bossStatus = ValueNotifier(null);
  final ValueNotifier<List<PokemonType>> bossTypes = ValueNotifier(const []);
  final ValueNotifier<String?> statusMessage = ValueNotifier(null);
  final ValueNotifier<String?> toastMessage = ValueNotifier(null);
  final Map<String, Future<Image>> _monsterSprites = {};
  List<SkillDefinition> skillOffer = const [];
  RunResult? _result;
  double _skillChoiceTimer = 0;
  double _victoryTimer = 0;
  double _toastTimer = 0;
  bool _isVictoryPending = false;
  bool _isDisposed = false;

  late final DungeonRoom room;
  late final StyledJoystick joystick;
  Player? player;
  RoomDirector? _roomDirector;

  Chapter get chapter => config.chapter;

  HeroDefinition get hero => config.hero;

  Color get projectileColor =>
      hero.isTrainer ? room.theme.accentColor : hero.accentColor;

  Iterable<Enemy> get livingEnemies =>
      world.children.whereType<Enemy>().where((enemy) => !enemy.isDefeated);

  RunResult? get result => _result;

  bool get isRunOver => _result != null;

  bool get hasPendingChest => _pendingChest != null;

  bool get isInventoryOpen => overlays.isActive(inventoryOverlay);

  bool get isPauseMenuOpen => overlays.isActive(pauseOverlay);

  bool get _hasBlockingOverlay => _blockingOverlays.any(overlays.isActive);

  @override
  Color backgroundColor() => const Color(0xFF0D2129);

  @override
  Future<void> onLoad() async {
    room = DungeonRoom(roomSize: _roomSize);
    world.add(room);
    camera.viewfinder.position = room.size / 2;
    joystick = StyledJoystick();
    camera.viewport.add(joystick);
    _startRun();
  }

  void _startRun() {
    final themes = chapter.themes;
    applyRoomTheme(themes.isEmpty ? RoomTheme.crypt : themes.first);
    final newPlayer = Player(joystick: joystick, hero: hero)
      ..position = room.size / 2;
    player = newPlayer;
    world.add(newPlayer);
    camera
      ..follow(newPlayer, snap: true)
      ..setBounds(
        Rectangle.fromLTWH(0, 0, room.size.x, room.size.y),
        considerViewport: true,
      );
    final roomDirector = RoomDirector(
      chapter: chapter,
      api: api,
      today: _today,
      random: _random,
    );
    _roomDirector = roomDirector;
    add(roomDirector);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final zoomToShowExtent = min(size.x, size.y) / _visibleWorldExtent;
    final zoomToStayInsideRoom = max(size.x, size.y) / _roomSize;
    camera.viewfinder.zoom = max(
      zoomToShowExtent,
      zoomToStayInsideRoom,
    ).clamp(zoomToStayInsideRoom, max(_maxZoom, zoomToStayInsideRoom));
  }

  @override
  void update(double dt) {
    for (final stepTime in FrameSteps.split(dt)) {
      super.update(stepTime);
      _tickTimers(stepTime);
      if (paused) {
        return;
      }
    }
  }

  void _tickTimers(double dt) {
    _tickToast(dt);
    _tickSkillChoice(dt);
    _tickVictory(dt);
  }

  void _tickToast(double dt) {
    if (_toastTimer <= 0) {
      return;
    }
    _toastTimer -= dt;
    if (_toastTimer <= 0) {
      toastMessage.value = null;
    }
  }

  void _tickSkillChoice(double dt) {
    if (_skillChoiceTimer <= 0) {
      return;
    }
    _skillChoiceTimer -= dt;
    if (_skillChoiceTimer <= 0) {
      _openSkillChoice();
    }
  }

  void _tickVictory(double dt) {
    if (!_isVictoryPending) {
      return;
    }
    _victoryTimer -= dt;
    final hasPickupsLeft = _activePickups.isNotEmpty;
    if (_victoryTimer <= 0 || !hasPickupsLeft) {
      _isVictoryPending = false;
      _finishRun(isVictory: true);
    }
  }

  void enterRoom(int newRoomNumber, RoomTheme theme) {
    applyRoomTheme(theme);
    roomNumber.value = newRoomNumber;
  }

  void onRoomCleared(int clearedRoom) {
    tracker.recordRoomCleared(clearedRoom);
    _attractPickups();
    if (chapter.isFinalBossRoom(clearedRoom)) {
      statusMessage.value = 'Chapitre terminé !';
      _isVictoryPending = true;
      _victoryTimer = _victoryMaxDelay;
      return;
    }
    statusMessage.value = 'Salle $clearedRoom terminée !';
    _skillChoiceTimer = _skillChoiceDelay;
    final hasChest = ChestSchedule.hasChestAfter(
      clearedRoom: clearedRoom,
      chapter: chapter,
      random: _random,
    );
    if (hasChest) {
      _spawnChest(clearedRoom);
    }
  }

  void _spawnChest(int clearedRoom) {
    final chest = TreasureChest(
      roomNumber: clearedRoom,
      position: room.size / 2,
    );
    _pendingChest = chest;
    world.add(chest);
  }

  void openChest(TreasureChest chest) {
    if (!identical(chest, _pendingChest)) {
      return;
    }
    _pendingChest = null;
    final reward = _chestLoot.roll(
      roomNumber: chest.roomNumber,
      difficulty: chapter.difficulty,
      excluded: _knownEquipment,
    );
    tracker.recordChestOpened();
    _applyChestReward(reward);
    showToast(reward.describe());
    _roomDirector?.holdNextRoom(_afterChestDelay);
  }

  void _applyChestReward(ChestReward reward) {
    tracker.recordCoinsCollected(reward.coins);
    coins.value = tracker.coinsEarned;
    final consumable = reward.consumable;
    if (consumable != null) {
      inventory.addConsumable(consumable);
    }
    final equipment = reward.equipment;
    if (equipment != null) {
      tracker.recordEquipmentFound(equipment);
    }
  }

  Iterable<Pickup> get _activePickups =>
      world.children.whereType<Pickup>().where((pickup) => !pickup.isRemoving);

  void _attractPickups() {
    for (final pickup in _activePickups) {
      pickup.attractToPlayer();
    }
  }

  void _openSkillChoice() {
    final currentPlayer = player;
    if (currentPlayer == null || currentPlayer.isDefeated || isRunOver) {
      return;
    }
    final offer = skills.draft(
      _random,
      isPlayerHurt: currentPlayer.hp < currentPlayer.stats.maxHp,
      size: HeroAbilityRules.skillDraftSize(hero.ability),
    );
    statusMessage.value = null;
    if (offer.isEmpty) {
      return;
    }
    skillOffer = offer;
    overlays.remove(inventoryOverlay);
    _showBlockingOverlay(skillChoiceOverlay);
  }

  void chooseSkill(SkillDefinition skill) {
    if (!overlays.isActive(skillChoiceOverlay)) {
      return;
    }
    skills.acquire(skill);
    player?.heal(_skillHealAmount(skill));
    skillOffer = const [];
    _hideBlockingOverlay(skillChoiceOverlay);
  }

  int _skillHealAmount(SkillDefinition skill) {
    final maxHp = player?.stats.maxHp ?? 0;
    return skill.healAmount + (maxHp * skill.healRatio).round();
  }

  void openInventory() {
    final currentPlayer = player;
    if (currentPlayer == null || currentPlayer.isDefeated) {
      return;
    }
    if (_hasBlockingOverlay) {
      return;
    }
    _showBlockingOverlay(inventoryOverlay);
  }

  void closeInventory() => _hideBlockingOverlay(inventoryOverlay);

  void openPauseMenu() {
    if (isRunOver || isPauseMenuOpen) {
      return;
    }
    _showBlockingOverlay(pauseOverlay);
  }

  void resumeFromPause() => _hideBlockingOverlay(pauseOverlay);

  void abandonRun() {
    if (isRunOver) {
      return;
    }
    _finishRun(isVictory: false);
  }

  void _showBlockingOverlay(String overlayName) {
    player?.stopFiring();
    overlays.add(overlayName);
    _syncEnginePause();
  }

  void _hideBlockingOverlay(String overlayName) {
    if (!overlays.isActive(overlayName)) {
      return;
    }
    overlays.remove(overlayName);
    _syncEnginePause();
  }

  void _syncEnginePause() {
    if (_hasBlockingOverlay) {
      pauseEngine();
      return;
    }
    resumeEngine();
  }

  bool useConsumable(ConsumableItem item) {
    final currentPlayer = player;
    if (currentPlayer == null || isRunOver || !inventory.consume(item)) {
      return false;
    }
    tracker.recordConsumableUsed();
    currentPlayer.applyConsumable(item);
    return true;
  }

  void showToast(String message) {
    toastMessage.value = message;
    _toastTimer = _toastDuration;
  }

  void applyRoomTheme(RoomTheme theme) {
    room.theme = theme;
    roomTheme.value = theme;
  }

  void showBoss(Enemy boss) {
    bossTypes.value = boss.types;
    bossStatus.value = BossStatus(
      title: _bossTitle(boss),
      name: boss.data.name,
      hpRatio: boss.hpRatio,
      isDailyEvent: boss.rank == EnemyRank.dailyLegendary,
    );
  }

  void _clearBoss() {
    bossStatus.value = null;
    bossTypes.value = const [];
  }

  String _bossTitle(Enemy boss) {
    if (boss.rank == EnemyRank.dailyLegendary) {
      return 'ÉVÉNEMENT DU JOUR';
    }
    return boss.isFinalBoss ? 'BOSS FINAL' : 'BOSS';
  }

  void onEnemyDamaged(Enemy enemy, {bool isDirectHit = true}) {
    if (isDirectHit) {
      player?.onEnemyHit();
    }
    if (enemy.isBoss) {
      showBoss(enemy);
    }
  }

  void onEnemyDefeated(Enemy enemy) {
    tracker.recordEnemyDefeated(enemy.rank, scoreValue: enemy.scoreValue);
    score.value = tracker.score;
    if (enemy.isBoss) {
      _clearBoss();
    }
    player?.heal(HeroAbilityRules.healOnDefeat(hero.ability));
    _dropLoot(enemy);
    _roomDirector?.notifyEnemyDefeated();
  }

  void spawnChainBounce({required Enemy source, required int hitDamage}) {
    final target = HeroAbilityRules.nearestWithin(
      origin: source.position,
      candidates: livingEnemies.where((enemy) => !identical(enemy, source)),
      positionOf: (enemy) => enemy.position,
    );
    if (target == null) {
      return;
    }
    final direction = target.position - source.position;
    if (direction.isZero()) {
      return;
    }
    world.add(
      Projectile(
        position: source.position.clone(),
        direction: direction,
        damage: HeroAbilityRules.chainDamage(hitDamage),
        color: projectileColor,
        ignoredEnemy: source,
      ),
    );
  }

  void _dropLoot(Enemy enemy) {
    _dropCoins(enemy);
    final droppedItem = _rollItemDrop(enemy.rank);
    if (droppedItem == null) {
      return;
    }
    world.add(
      Pickup.item(
        position: enemy.position.clone(),
        item: droppedItem,
        random: _random,
      ),
    );
  }

  void _dropCoins(Enemy enemy) {
    final coinTotal = _lootTable.coinsFor(
      enemyMaxHp: enemy.maxHp,
      multiplier: enemy.rank.coinMultiplier,
    );
    final pickupCount = min(coinTotal, _maxCoinPickupsPerEnemy);
    for (var index = 0; index < pickupCount; index++) {
      final share =
          coinTotal ~/ pickupCount + (index < coinTotal % pickupCount ? 1 : 0);
      world.add(
        Pickup.coins(
          position: enemy.position.clone(),
          coinValue: share,
          random: _random,
        ),
      );
    }
  }

  ItemDefinition? _rollItemDrop(EnemyRank rank) => switch (rank) {
    EnemyRank.normal => _lootTable.rollConsumableDrop(),
    EnemyRank.boss => _lootTable.rollBossEquipment(excluded: _knownEquipment),
    EnemyRank.dailyLegendary => _lootTable.rollDailyEventReward(
      excluded: _knownEquipment,
    ),
  };

  List<EquipmentItem> get _knownEquipment => [
    ...inventory.equippedItems,
    ...tracker.foundEquipment,
  ];

  void collectPickup(Pickup pickup) {
    switch (pickup.item) {
      case null:
        tracker.recordCoinsCollected(pickup.coinValue);
        coins.value = tracker.coinsEarned;
      case final EquipmentItem equipment:
        if (tracker.recordEquipmentFound(equipment)) {
          showToast('Trouvé : ${equipment.name}');
        }
      case final ConsumableItem consumable:
        inventory.addConsumable(consumable);
        showToast('Obtenu : ${consumable.name}');
    }
  }

  void _collectRemainingPickups() {
    for (final pickup in _activePickups.toList()) {
      collectPickup(pickup);
      pickup.removeFromParent();
    }
  }

  void onPlayerDefeated() => _finishRun(isVictory: false);

  void _finishRun({required bool isVictory}) {
    if (isRunOver) {
      return;
    }
    if (isVictory) {
      _collectRemainingPickups();
    }
    _skillChoiceTimer = 0;
    _isVictoryPending = false;
    statusMessage.value = null;
    _clearBoss();
    _result = tracker.buildResult(
      isVictory: isVictory,
      unusedConsumables: inventory.consumables,
    );
    overlays.removeAll([
      hudOverlay,
      inventoryOverlay,
      skillChoiceOverlay,
      pauseOverlay,
    ]);
    _showBlockingOverlay(runSummaryOverlay);
  }

  /// Throws [PokeApiException].
  Future<Image> loadMonsterSprite(String spriteUrl) {
    if (_isDisposed) {
      throw const PokeApiException('Partie terminée');
    }
    return _monsterSprites[spriteUrl] ??= _decodeMonsterSprite(spriteUrl);
  }

  Future<Image> _decodeMonsterSprite(String spriteUrl) async {
    try {
      final bytes = await api.fetchSpriteBytes(spriteUrl);
      final image = await decodeImageFromList(bytes);
      if (_isDisposed) {
        image.dispose();
        throw const PokeApiException('Partie terminée');
      }
      return image;
    } on PokeApiException {
      _monsterSprites.remove(spriteUrl);
      rethrow;
    } on Exception catch (error) {
      _monsterSprites.remove(spriteUrl);
      throw PokeApiException('Sprite illisible $spriteUrl ($error)');
    }
  }

  @override
  void onDispose() {
    super.onDispose();
    dispose();
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    super.dispose();
    _isDisposed = true;
    _roomDirector = null;
    player = null;
    _releaseSprites();
    _disposeNotifiers();
  }

  void _releaseSprites() {
    for (final sprite in _monsterSprites.values) {
      sprite.then((image) => image.dispose(), onError: (_) {});
    }
    _monsterSprites.clear();
  }

  void _disposeNotifiers() {
    for (final notifier in <ChangeNotifier>[
      score,
      coins,
      roomNumber,
      playerHp,
      playerMaxHp,
      activeBoosts,
      roomTheme,
      bossStatus,
      bossTypes,
      statusMessage,
      toastMessage,
      inventory,
      skills,
    ]) {
      notifier.dispose();
    }
  }
}
