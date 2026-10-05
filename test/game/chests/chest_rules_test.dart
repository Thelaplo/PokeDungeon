import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/chapters/chapter_catalog.dart';
import 'package:poke_dungeon/game/chests/chest_loot.dart';
import 'package:poke_dungeon/game/chests/chest_schedule.dart';
import 'package:poke_dungeon/game/items/item_catalog.dart';

import '../support/scripted_random.dart';

final chapterOne = ChapterCatalog.byNumber(1);

bool hasChestAfter(int room, {required double roll}) =>
    ChestSchedule.hasChestAfter(
      clearedRoom: room,
      chapter: chapterOne,
      random: ScriptedRandom([roll]),
    );

void main() {
  group('chest schedule', () {
    test('rooms 3 and 7 always hold a chest', () {
      expect(hasChestAfter(3, roll: 0.99), isTrue);
      expect(hasChestAfter(7, roll: 0.99), isTrue);
    });

    test('the final room never holds a chest', () {
      expect(hasChestAfter(chapterOne.roomCount, roll: 0), isFalse);
    });

    test('other rooms hold a chest thirty percent of the time', () {
      expect(hasChestAfter(1, roll: 0.29), isTrue);
      expect(hasChestAfter(5, roll: 0.1), isTrue);
      expect(hasChestAfter(1, roll: 0.3), isFalse);
      expect(hasChestAfter(8, roll: 0.9), isFalse);
    });

    test('a seeded run gets roughly thirty percent of random chests', () {
      final random = Random(42);
      var chestCount = 0;
      const draws = 2000;
      for (var draw = 0; draw < draws; draw++) {
        if (ChestSchedule.hasChestAfter(
          clearedRoom: 2,
          chapter: chapterOne,
          random: random,
        )) {
          chestCount++;
        }
      }

      expect(chestCount / draws, closeTo(0.3, 0.04));
    });
  });

  group('chest loot', () {
    test('coins grow with the room and the chapter difficulty', () {
      expect(ChestLoot.coinsFor(roomNumber: 1, difficulty: 1), 26);
      expect(ChestLoot.coinsFor(roomNumber: 5, difficulty: 2), 100);
      expect(
        ChestLoot.coinsFor(roomNumber: 7, difficulty: 1),
        greaterThan(ChestLoot.coinsFor(roomNumber: 3, difficulty: 1)),
      );
    });

    test('room 7 has a better equipment chance', () {
      expect(ChestLoot.equipmentChanceFor(7), 0.4);
      expect(ChestLoot.equipmentChanceFor(3), 0.15);
    });

    test('a lucky chest holds a consumable and equipment', () {
      final reward = ChestLoot(random: ScriptedRandom([0.1, 0.1]))
          .roll(roomNumber: 3, difficulty: 1);

      expect(reward.coins, ChestLoot.coinsFor(roomNumber: 3, difficulty: 1));
      expect(reward.consumable, ItemCatalog.potion);
      expect(reward.equipment, isNotNull);
      expect(
        reward.describe(),
        'Coffre : +${reward.coins} ₽ · ${ItemCatalog.potion.name} · '
        '${reward.equipment!.name}',
      );
    });

    test('an unlucky chest only holds coins', () {
      final reward = ChestLoot(random: ScriptedRandom([0.6, 0.15]))
          .roll(roomNumber: 3, difficulty: 1);

      expect(reward.consumable, isNull);
      expect(reward.equipment, isNull);
      expect(reward.describe(), 'Coffre : +${reward.coins} ₽');
    });

    test('the same roll gives equipment in room 7 but not in room 3', () {
      expect(
        ChestLoot(random: ScriptedRandom([0.9, 0.3]))
            .roll(roomNumber: 7, difficulty: 1)
            .hasEquipment,
        isTrue,
      );
      expect(
        ChestLoot(random: ScriptedRandom([0.9, 0.3]))
            .roll(roomNumber: 3, difficulty: 1)
            .hasEquipment,
        isFalse,
      );
    });

    test('a chest never gives equipment already known', () {
      final excluded = ItemCatalog.equipment
          .where((item) => item != ItemCatalog.leftovers)
          .toList();

      final reward = ChestLoot(random: ScriptedRandom([0.9, 0.1]))
          .roll(roomNumber: 7, difficulty: 1, excluded: excluded);

      expect(reward.equipment, ItemCatalog.leftovers);
    });

    test('seeded chests drop a consumable about sixty percent of the time', () {
      final loot = ChestLoot(random: Random(7));
      var consumableCount = 0;
      const draws = 2000;
      for (var draw = 0; draw < draws; draw++) {
        if (loot.roll(roomNumber: 2, difficulty: 1).consumable != null) {
          consumableCount++;
        }
      }

      expect(consumableCount / draws, closeTo(0.6, 0.04));
    });
  });
}
