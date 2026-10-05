class MonsterData {
  const MonsterData({
    required this.id,
    required this.name,
    required this.baseHp,
    required this.attack,
    required this.speed,
    required this.spriteUrl,
    required this.types,
  });

  final int id;
  final String name;
  final int baseHp;
  final int attack;
  final double speed;
  final String spriteUrl;
  final List<String> types;
}
