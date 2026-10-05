import 'package:flutter/material.dart';

import '../../../models/daily_quest.dart';

extension QuestMetricIcon on QuestMetric {
  IconData get icon => switch (this) {
    QuestMetric.enemiesDefeated => Icons.catching_pokemon,
    QuestMetric.bossesDefeated => Icons.whatshot_rounded,
    QuestMetric.roomsCleared => Icons.door_front_door_rounded,
    QuestMetric.coinsEarned => Icons.savings_rounded,
    QuestMetric.consumablesUsed => Icons.local_drink_rounded,
    QuestMetric.dailyEventDefeated => Icons.auto_awesome_rounded,
    QuestMetric.chaptersCompleted => Icons.flag_rounded,
    QuestMetric.runsPlayed => Icons.directions_run_rounded,
  };
}
