import '../models/daily_quest.dart';

extension DailyQuestCopy on DailyQuest {
  DailyQuest copyWith({int? progress, bool? isClaimed}) => DailyQuest(
    id: id,
    description: description,
    metric: metric,
    target: target,
    progress: progress ?? this.progress,
    reward: reward,
    isClaimed: isClaimed ?? this.isClaimed,
  );

  DailyQuest advancedBy(int amount) {
    if (amount <= 0) return this;
    final advancedProgress = progress + amount;
    return copyWith(
      progress: advancedProgress > target ? target : advancedProgress,
    );
  }
}
