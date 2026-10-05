import '../models/daily_quest.dart';
import '../models/run_result.dart';

extension RunResultQuestMetrics on RunResult {
  int amountFor(QuestMetric metric) => switch (metric) {
    QuestMetric.enemiesDefeated => enemiesDefeated,
    QuestMetric.bossesDefeated => bossesDefeated,
    QuestMetric.roomsCleared => roomsCleared,
    QuestMetric.coinsEarned => coinsEarned,
    QuestMetric.consumablesUsed => consumablesUsed,
    QuestMetric.dailyEventDefeated => isDailyEventDefeated ? 1 : 0,
    QuestMetric.chaptersCompleted => isVictory ? 1 : 0,
    QuestMetric.runsPlayed => 1,
  };
}
