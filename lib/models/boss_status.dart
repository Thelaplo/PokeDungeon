class BossStatus {
  const BossStatus({
    required this.title,
    required this.name,
    required this.hpRatio,
    required this.isDailyEvent,
  });

  final String title;
  final String name;
  final double hpRatio;
  final bool isDailyEvent;
}
