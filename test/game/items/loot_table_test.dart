import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/items/item_catalog.dart';
import 'package:poke_dungeon/game/items/loot_table.dart';
import 'package:poke_dungeon/models/item_definition.dart';

class FixedRandom implements Random {
  FixedRandom({required this.doubleValue});

  final double doubleValue;

  @override
  double nextDouble() => doubleValue;

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => false;
}

Iterable<EquipmentItem> equipmentWhere(bool Function(EquipmentItem) test) =>
    ItemCatalog.equipment.where(test);

void main() {
  group('coins', () {
    test('coins follow the enemy hp and the multiplier', () {
      final lootTable = LootTable(random: Random(1));

      expect(lootTable.coinsFor(enemyMaxHp: 60), 10);
      expect(lootTable.coinsFor(enemyMaxHp: 60, multiplier: 5), 50);
    });

    test('a weak enemy still drops one coin', () {
      expect(LootTable(random: Random(1)).coinsFor(enemyMaxHp: 1), 1);
    });
  });

  group('consumable drops', () {
    test('no consumable drops above the drop chance', () {
      final lootTable = LootTable(random: FixedRandom(doubleValue: 0.99));

      expect(lootTable.rollConsumableDrop(), isNull);
    });

    test('a consumable drops below the drop chance', () {
      final lootTable = LootTable(random: FixedRandom(doubleValue: 0));

      expect(lootTable.rollConsumableDrop(), ItemCatalog.potion);
    });
  });

  group('boss equipment', () {
    test('a boss drops rare or better equipment', () {
      final lootTable = LootTable(random: Random(3));
      for (var draw = 0; draw < 100; draw++) {
        final item = lootTable.rollBossEquipment();

        expect(item, isNotNull);
        expect(item!.rarity.index, greaterThanOrEqualTo(ItemRarity.rare.index));
      }
    });

    test('a boss never drops excluded equipment', () {
      final remainingItem = ItemCatalog.leftovers;
      final excluded = equipmentWhere((item) => item != remainingItem);
      final lootTable = LootTable(random: Random(3));

      for (var draw = 0; draw < 20; draw++) {
        expect(lootTable.rollBossEquipment(excluded: excluded), remainingItem);
      }
    });

    test('a boss drops nothing once everything is excluded', () {
      final lootTable = LootTable(random: Random(3));

      expect(
        lootTable.rollBossEquipment(excluded: ItemCatalog.equipment),
        isNull,
      );
    });
  });

  group('daily event reward', () {
    test('the daily legendary drops legendary equipment first', () {
      final lootTable = LootTable(random: Random(5));
      for (var draw = 0; draw < 50; draw++) {
        expect(lootTable.rollDailyEventReward()?.rarity, ItemRarity.legendary);
      }
    });

    test('the reward falls back to epic equipment', () {
      final lootTable = LootTable(random: Random(5));
      final legendaries = equipmentWhere(
        (item) => item.rarity == ItemRarity.legendary,
      );

      expect(
        lootTable.rollDailyEventReward(excluded: legendaries)?.rarity,
        ItemRarity.epic,
      );
    });

    test('the reward is empty once epic and legendary are excluded', () {
      final lootTable = LootTable(random: Random(5));
      final highTier = equipmentWhere(
        (item) => item.rarity.index >= ItemRarity.epic.index,
      );

      expect(lootTable.rollDailyEventReward(excluded: highTier), isNull);
    });
  });
}
