import '../models/item_definition.dart';

enum ChestType {
  pokeBall(
    label: 'Poké Ball',
    gemCost: ChestType.pokeBallGemCost,
    rarityWeights: {
      ItemRarity.common: 50,
      ItemRarity.rare: 30,
      ItemRarity.epic: 15,
      ItemRarity.legendary: 5,
    },
  ),
  hyperBall(
    label: 'Hyper Ball',
    gemCost: 300,
    rarityWeights: {
      ItemRarity.common: 0,
      ItemRarity.rare: 55,
      ItemRarity.epic: 35,
      ItemRarity.legendary: 10,
    },
  );

  const ChestType({
    required this.label,
    required this.gemCost,
    required this.rarityWeights,
  });

  static const pokeBallGemCost = 100;

  final String label;
  final int gemCost;
  final Map<ItemRarity, int> rarityWeights;
}
