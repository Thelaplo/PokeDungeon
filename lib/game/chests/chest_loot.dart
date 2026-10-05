import 'dart:math';

import '../../models/item_definition.dart';
import '../items/loot_table.dart';
import 'chest_reward.dart';

class ChestLoot {
  ChestLoot({required Random random})
    : _random = random,
      _lootTable = LootTable(random: random);

  static const baseCoins = 20;
  static const coinsPerRoom = 6;
  static const consumableChance = 0.6;
  static const equipmentChance = 0.15;
  static const bonusEquipmentRoom = 7;
  static const bonusEquipmentChance = 0.4;

  final Random _random;
  final LootTable _lootTable;

  static int coinsFor({required int roomNumber, required double difficulty}) =>
      max(1, ((baseCoins + roomNumber * coinsPerRoom) * difficulty).round());

  static double equipmentChanceFor(int roomNumber) =>
      roomNumber == bonusEquipmentRoom ? bonusEquipmentChance : equipmentChance;

  ChestReward roll({
    required int roomNumber,
    required double difficulty,
    Iterable<EquipmentItem> excluded = const [],
  }) {
    final hasConsumable = _random.nextDouble() < consumableChance;
    final consumable = hasConsumable
        ? _lootTable.rollWeightedConsumable()
        : null;
    final hasEquipment = _random.nextDouble() < equipmentChanceFor(roomNumber);
    final equipment = hasEquipment
        ? _lootTable.rollChestEquipment(excluded: excluded)
        : null;
    return ChestReward(
      coins: coinsFor(roomNumber: roomNumber, difficulty: difficulty),
      consumable: consumable,
      equipment: equipment,
    );
  }
}
