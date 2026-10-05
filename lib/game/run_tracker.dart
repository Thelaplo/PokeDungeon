import 'dart:math';

import '../models/enemy_rank.dart';
import '../models/item_definition.dart';
import '../models/run_result.dart';

class RunTracker {
  RunTracker({required this.chapterNumber});

  final int chapterNumber;
  final List<EquipmentItem> _foundEquipment = [];
  int _roomsCleared = 0;
  int _score = 0;
  int _coinsEarned = 0;
  int _enemiesDefeated = 0;
  int _bossesDefeated = 0;
  int _consumablesUsed = 0;
  int _chestsOpened = 0;
  bool _isDailyEventDefeated = false;

  int get roomsCleared => _roomsCleared;

  int get score => _score;

  int get coinsEarned => _coinsEarned;

  int get enemiesDefeated => _enemiesDefeated;

  int get bossesDefeated => _bossesDefeated;

  int get consumablesUsed => _consumablesUsed;

  int get chestsOpened => _chestsOpened;

  bool get isDailyEventDefeated => _isDailyEventDefeated;

  List<EquipmentItem> get foundEquipment => List.unmodifiable(_foundEquipment);

  void recordEnemyDefeated(EnemyRank rank, {required int scoreValue}) {
    _enemiesDefeated++;
    _score += max(0, scoreValue);
    switch (rank) {
      case EnemyRank.normal:
        break;
      case EnemyRank.boss:
        _bossesDefeated++;
      case EnemyRank.dailyLegendary:
        _isDailyEventDefeated = true;
    }
  }

  void recordRoomCleared(int roomNumber) {
    _roomsCleared = max(_roomsCleared, roomNumber);
  }

  void recordCoinsCollected(int amount) {
    if (amount <= 0) {
      return;
    }
    _coinsEarned += amount;
  }

  void recordConsumableUsed() {
    _consumablesUsed++;
  }

  void recordChestOpened() {
    _chestsOpened++;
  }

  bool recordEquipmentFound(EquipmentItem item) {
    if (_foundEquipment.contains(item)) {
      return false;
    }
    _foundEquipment.add(item);
    return true;
  }

  RunResult buildResult({
    required bool isVictory,
    required Map<ConsumableItem, int> unusedConsumables,
  }) => RunResult(
    chapterNumber: chapterNumber,
    roomsCleared: _roomsCleared,
    isVictory: isVictory,
    score: _score,
    coinsEarned: _coinsEarned,
    enemiesDefeated: _enemiesDefeated,
    bossesDefeated: _bossesDefeated,
    isDailyEventDefeated: _isDailyEventDefeated,
    consumablesUsed: _consumablesUsed,
    foundEquipment: List.unmodifiable(_foundEquipment),
    unusedConsumables: Map.unmodifiable({
      for (final MapEntry(key: item, value: count) in unusedConsumables.entries)
        if (count > 0) item: count,
    }),
  );
}
