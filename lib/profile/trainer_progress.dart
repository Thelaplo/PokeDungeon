class TrainerProgress {
  const TrainerProgress({required this.level, required this.xpIntoLevel});

  static const initial = TrainerProgress(level: 1, xpIntoLevel: 0);
  static const _baseXpPerLevel = 100;
  static const _xpGrowthPerLevel = 60;

  final int level;
  final int xpIntoLevel;

  int get xpForNextLevel => xpRequiredAt(level);

  static int xpRequiredAt(int level) =>
      _baseXpPerLevel + _xpGrowthPerLevel * (level - 1);

  TrainerProgress addXp(int xp) {
    if (xp <= 0) return this;
    var reachedLevel = level;
    var remainingXp = xpIntoLevel + xp;
    while (remainingXp >= xpRequiredAt(reachedLevel)) {
      remainingXp -= xpRequiredAt(reachedLevel);
      reachedLevel++;
    }
    return TrainerProgress(level: reachedLevel, xpIntoLevel: remainingXp);
  }
}
