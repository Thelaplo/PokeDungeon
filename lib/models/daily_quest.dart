enum QuestMetric {
  enemiesDefeated,
  bossesDefeated,
  roomsCleared,
  coinsEarned,
  consumablesUsed,
  dailyEventDefeated,
  chaptersCompleted,
  runsPlayed,
}

class QuestReward {
  const QuestReward({this.coins = 0, this.gems = 0, this.xp = 0});

  final int coins;
  final int gems;
  final int xp;
}

class DailyQuest {
  const DailyQuest({
    required this.id,
    required this.description,
    required this.metric,
    required this.target,
    required this.progress,
    required this.reward,
    required this.isClaimed,
  });

  final String id;
  final String description;
  final QuestMetric metric;
  final int target;
  final int progress;
  final QuestReward reward;
  final bool isClaimed;

  bool get isCompleted => progress >= target;

  bool get canClaim => isCompleted && !isClaimed;

  double get progressRatio => (progress / target).clamp(0.0, 1.0);
}
