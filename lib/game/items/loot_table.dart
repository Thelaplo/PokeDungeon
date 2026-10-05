import 'dart:math';

import '../../models/item_definition.dart';
import 'item_catalog.dart';

class LootTable {
  LootTable({Random? random}) : _random = random ?? Random();

  static const consumableDropChance = 0.12;
  static const _hpPerCoin = 6;
  static const _consumableWeights = {
    ItemCatalog.potion: 55,
    ItemCatalog.superPotion: 22,
    ItemCatalog.xAttack: 9,
    ItemCatalog.xSpeed: 9,
    ItemCatalog.hyperPotion: 5,
  };

  final Random _random;

  int coinsFor({required int enemyMaxHp, int multiplier = 1}) =>
      max(1, enemyMaxHp ~/ _hpPerCoin) * multiplier;

  ConsumableItem? rollConsumableDrop() {
    if (_random.nextDouble() >= consumableDropChance) {
      return null;
    }
    return rollWeightedConsumable();
  }

  EquipmentItem? rollChestEquipment({
    Iterable<EquipmentItem> excluded = const [],
  }) => _rollEquipment(excluded, minimumRarity: ItemRarity.common);

  ConsumableItem rollWeightedConsumable() {
    final totalWeight = _consumableWeights.values.reduce(
      (sum, weight) => sum + weight,
    );
    var roll = _random.nextInt(totalWeight);
    for (final MapEntry(key: item, value: weight)
        in _consumableWeights.entries) {
      if (roll < weight) {
        return item;
      }
      roll -= weight;
    }
    return ItemCatalog.potion;
  }

  EquipmentItem? rollBossEquipment({
    Iterable<EquipmentItem> excluded = const [],
  }) => _rollEquipment(excluded, minimumRarity: ItemRarity.rare);

  EquipmentItem? rollDailyEventReward({
    Iterable<EquipmentItem> excluded = const [],
  }) =>
      _rollEquipment(excluded, minimumRarity: ItemRarity.legendary) ??
      _rollEquipment(excluded, minimumRarity: ItemRarity.epic);

  EquipmentItem? _rollEquipment(
    Iterable<EquipmentItem> excluded, {
    required ItemRarity minimumRarity,
  }) {
    final excludedItems = excluded.toSet();
    final candidates = ItemCatalog.equipment
        .where((item) => item.rarity.index >= minimumRarity.index)
        .where((item) => !excludedItems.contains(item))
        .toList();
    if (candidates.isEmpty) {
      return null;
    }
    return candidates[_random.nextInt(candidates.length)];
  }
}
