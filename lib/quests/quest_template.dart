import '../models/daily_quest.dart';

class QuestTier {
  const QuestTier({required this.target, required this.reward});

  final int target;
  final QuestReward reward;
}

class QuestTemplate {
  const QuestTemplate({
    required this.metric,
    required this.describe,
    required this.tiers,
  });

  final QuestMetric metric;
  final String Function(int target) describe;
  final List<QuestTier> tiers;
}
