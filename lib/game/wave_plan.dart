import 'dart:math';

import '../models/chapter.dart';
import '../models/room_theme.dart';

class WavePlan {
  const WavePlan({
    required this.chapter,
    required this.roomNumber,
    this.dailyEventRoom = 0,
  }) : assert(roomNumber >= 1);

  static const bossWaveInterval = 5;
  static const legendaryIds = [144, 145, 146, 150, 151];
  static const bossPoolIds = [
    3,
    6,
    9,
    31,
    34,
    59,
    65,
    68,
    76,
    94,
    112,
    115,
    130,
    131,
    142,
    143,
    149,
  ];
  static const firstEventWave = 3;
  static const lastEventWave = 9;
  static const miniBossMinionCount = 2;
  static const finalBossMinionCount = 3;
  static const _baseEnemyCount = 2;
  static const _maxEnemyCount = 10;
  static const _hpGrowthPerRoom = 0.08;
  static const _bossHpMultiplier = 3.5;
  static const _finalBossHpMultiplier = 6.0;
  static const _legendaryHpMultiplier = 5.0;
  static const _contactDamageGrowthPerDifficulty = 0.5;

  final Chapter chapter;
  final int roomNumber;
  final int dailyEventRoom;

  bool get isFinalBossRoom => chapter.isFinalBossRoom(roomNumber);

  bool get isMiniBossRoom =>
      !isFinalBossRoom && chapter.isMiniBossRoom(roomNumber);

  bool get isBossRoom => isFinalBossRoom || isMiniBossRoom;

  bool get isDailyEventRoom => !isBossRoom && roomNumber == dailyEventRoom;

  int get enemyCount {
    if (isFinalBossRoom) {
      return finalBossMinionCount;
    }
    if (isMiniBossRoom) {
      return miniBossMinionCount;
    }
    return min(_baseEnemyCount + roomNumber, _maxEnemyCount);
  }

  RoomTheme get theme {
    final themes = chapter.themes;
    if (themes.isEmpty) {
      return RoomTheme.crypt;
    }
    return themes[(roomNumber - 1) % themes.length];
  }

  double get enemyHpMultiplier =>
      chapter.difficulty * (1 + (roomNumber - 1) * _hpGrowthPerRoom);

  double get bossHpMultiplier => enemyHpMultiplier * _bossHpMultiplier;

  double get finalBossHpMultiplier =>
      enemyHpMultiplier * _finalBossHpMultiplier;

  double get legendaryHpMultiplier =>
      enemyHpMultiplier * _legendaryHpMultiplier;

  double get contactDamageMultiplier =>
      1 + max(0, chapter.difficulty - 1) * _contactDamageGrowthPerDifficulty;

  static int randomBossId(Random random, {int? excludedId}) {
    final candidates = bossPoolIds.where((id) => id != excludedId).toList();
    return candidates[random.nextInt(candidates.length)];
  }

  static Random _dailyRandom(DateTime date) =>
      Random(date.year * 10000 + date.month * 100 + date.day);

  static int dailyLegendaryId(DateTime date) =>
      legendaryIds[_dailyRandom(date).nextInt(legendaryIds.length)];

  static int dailyEventWaveFor(DateTime date) {
    final eventWaves = [
      for (var wave = firstEventWave; wave <= lastEventWave; wave++)
        if (wave % bossWaveInterval != 0) wave,
    ];
    final random = _dailyRandom(date)..nextInt(legendaryIds.length);
    return eventWaves[random.nextInt(eventWaves.length)];
  }
}
