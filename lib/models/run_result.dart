import 'item_definition.dart';

class RunResult {
  const RunResult({
    required this.chapterNumber,
    required this.roomsCleared,
    required this.isVictory,
    required this.score,
    required this.coinsEarned,
    required this.enemiesDefeated,
    required this.bossesDefeated,
    required this.isDailyEventDefeated,
    required this.consumablesUsed,
    required this.foundEquipment,
    required this.unusedConsumables,
  });

  final int chapterNumber;
  final int roomsCleared;
  final bool isVictory;
  final int score;
  final int coinsEarned;
  final int enemiesDefeated;
  final int bossesDefeated;
  final bool isDailyEventDefeated;
  final int consumablesUsed;
  final List<EquipmentItem> foundEquipment;
  final Map<ConsumableItem, int> unusedConsumables;
}
