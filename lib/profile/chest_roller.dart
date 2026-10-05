import 'dart:math';

import '../game/items/item_catalog.dart';
import '../models/item_definition.dart';
import 'chest_type.dart';

class ChestRoller {
  ChestRoller(this._random);

  final Random _random;

  EquipmentItem roll(ChestType type) {
    final rarity = _rollRarity(type.rarityWeights);
    final sameRarityItems = ItemCatalog.equipment
        .where((item) => item.rarity == rarity)
        .toList();
    final candidates = sameRarityItems.isEmpty
        ? ItemCatalog.equipment.toList()
        : sameRarityItems;
    return candidates[_random.nextInt(candidates.length)];
  }

  ItemRarity _rollRarity(Map<ItemRarity, int> rarityWeights) {
    final totalWeight = rarityWeights.values.reduce(
      (runningTotal, weight) => runningTotal + weight,
    );
    var ticket = _random.nextInt(totalWeight);
    for (final rarityWeight in rarityWeights.entries) {
      if (ticket < rarityWeight.value) return rarityWeight.key;
      ticket -= rarityWeight.value;
    }
    return rarityWeights.keys.last;
  }
}
