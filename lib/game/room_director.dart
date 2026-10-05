import 'dart:math';

import 'package:flame/components.dart';

import '../models/chapter.dart';
import '../models/enemy_rank.dart';
import '../models/monster_data.dart';
import '../services/poke_api_service.dart';
import 'components/enemy.dart';
import 'dungeon_game.dart';
import 'wave_plan.dart';

class RoomDirector extends Component with HasGameReference<DungeonGame> {
  RoomDirector({
    required this.chapter,
    required this.api,
    required DateTime today,
    Random? random,
  }) : _today = today,
       _dailyEventRoom = WavePlan.dailyEventWaveFor(today),
       _random = random ?? Random();

  static const _firstRoomDelay = 1.0;
  static const _interRoomDelay = 2.5;
  static const _retryDelay = 4.0;
  static const _minSpawnDistance = 260.0;
  static const _spawnAttempts = 12;

  final Chapter chapter;
  final PokeApiService api;
  final DateTime _today;
  final int _dailyEventRoom;
  final Random _random;
  int _roomNumber = 0;
  int _aliveEnemies = 0;
  bool _isSpawning = false;
  double _nextRoomTimer = _firstRoomDelay;

  bool get hasRoomsLeft => _roomNumber < chapter.roomCount;

  @override
  void update(double dt) {
    super.update(dt);
    if (_isSpawning || _aliveEnemies > 0 || !hasRoomsLeft) {
      return;
    }
    if (game.hasPendingChest) {
      return;
    }
    _nextRoomTimer -= dt;
    if (_nextRoomTimer <= 0) {
      _startRoom(_roomNumber + 1);
    }
  }

  void holdNextRoom(double seconds) {
    _nextRoomTimer = max(_nextRoomTimer, seconds);
  }

  void notifyEnemyDefeated() {
    _aliveEnemies = max(0, _aliveEnemies - 1);
    if (_aliveEnemies > 0 || _isSpawning) {
      return;
    }
    _nextRoomTimer = _interRoomDelay;
    game.onRoomCleared(_roomNumber);
  }

  Future<void> _startRoom(int roomNumber) async {
    _isSpawning = true;
    final plan = WavePlan(
      chapter: chapter,
      roomNumber: roomNumber,
      dailyEventRoom: _dailyEventRoom,
    );
    game.statusMessage.value = _announcementFor(plan);
    try {
      final spawns = await _loadSpawns(plan);
      if (!isMounted) {
        return;
      }
      _roomNumber = roomNumber;
      game.enterRoom(roomNumber, plan.theme);
      for (final enemy in spawns) {
        game.world.add(enemy);
      }
      _aliveEnemies = spawns.length;
      game.statusMessage.value = null;
      spawns.where((enemy) => enemy.isBoss).forEach(game.showBoss);
      _announceLegendaries(spawns);
    } on PokeApiException {
      if (!isMounted) {
        return;
      }
      _nextRoomTimer = _retryDelay;
      game.statusMessage.value = 'PokéAPI injoignable, nouvel essai…';
    } finally {
      _isSpawning = false;
    }
  }

  String _announcementFor(WavePlan plan) {
    if (plan.isFinalBossRoom) {
      return 'Le boss final approche…';
    }
    if (plan.isMiniBossRoom) {
      return 'Un boss approche…';
    }
    return 'Salle ${plan.roomNumber} · ${plan.theme.roomName}';
  }

  void _announceLegendaries(List<Enemy> spawns) {
    for (final legendary in spawns.where(
      (enemy) => enemy.rank == EnemyRank.dailyLegendary,
    )) {
      game.showToast('ÉVÉNEMENT ! ${legendary.data.name} sauvage apparaît !');
    }
  }

  Future<List<Enemy>> _loadSpawns(WavePlan plan) async {
    final enemies = await _loadMinions(plan);
    if (plan.isMiniBossRoom) {
      final bossId = WavePlan.randomBossId(
        _random,
        excludedId: chapter.finalBossId,
      );
      enemies.add(
        await _buildEnemy(
          await api.fetchMonster(bossId),
          plan,
          hpMultiplier: plan.bossHpMultiplier,
          rank: EnemyRank.boss,
        ),
      );
    }
    if (plan.isFinalBossRoom) {
      enemies.add(
        await _buildEnemy(
          await api.fetchMonster(chapter.finalBossId),
          plan,
          hpMultiplier: plan.finalBossHpMultiplier,
          rank: EnemyRank.boss,
          isFinalBoss: true,
        ),
      );
    }
    if (plan.isDailyEventRoom) {
      enemies.add(
        await _buildEnemy(
          await api.fetchMonster(WavePlan.dailyLegendaryId(_today)),
          plan,
          hpMultiplier: plan.legendaryHpMultiplier,
          rank: EnemyRank.dailyLegendary,
        ),
      );
    }
    return enemies;
  }

  Future<List<Enemy>> _loadMinions(WavePlan plan) async {
    final pokemonType = plan.theme.pokemonType;
    final typeIds = await api.fetchFirstGenerationIdsOfType(pokemonType);
    if (typeIds.isEmpty) {
      throw PokeApiException('Aucun Pokémon de type $pokemonType');
    }
    final pickedIds = List.generate(
      plan.enemyCount,
      (_) => typeIds[_random.nextInt(typeIds.length)],
    );
    final monsters = await Future.wait(pickedIds.map(api.fetchMonster));
    return Future.wait(
      monsters.map(
        (monster) =>
            _buildEnemy(monster, plan, hpMultiplier: plan.enemyHpMultiplier),
      ),
    );
  }

  Future<Enemy> _buildEnemy(
    MonsterData monster,
    WavePlan plan, {
    required double hpMultiplier,
    EnemyRank rank = EnemyRank.normal,
    bool isFinalBoss = false,
  }) async {
    final spriteImage = await game.loadMonsterSprite(monster.spriteUrl);
    return Enemy(
      data: monster,
      spriteImage: spriteImage,
      position: _randomSpawnPosition(),
      hpMultiplier: hpMultiplier,
      rank: rank,
      contactDamageMultiplier: plan.contactDamageMultiplier,
      isFinalBoss: isFinalBoss,
    );
  }

  Vector2 _randomSpawnPosition() {
    final area = game.room.playableArea.deflate(48);
    final playerPosition =
        game.player?.position ?? Vector2(area.center.dx, area.center.dy);
    var candidate = Vector2.zero();
    for (var attempt = 0; attempt < _spawnAttempts; attempt++) {
      candidate = Vector2(
        area.left + _random.nextDouble() * area.width,
        area.top + _random.nextDouble() * area.height,
      );
      if (candidate.distanceTo(playerPosition) >= _minSpawnDistance) {
        return candidate;
      }
    }
    return candidate;
  }
}
