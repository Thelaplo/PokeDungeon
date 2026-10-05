import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/chapters/chapter_catalog.dart';
import 'package:poke_dungeon/game/items/item_catalog.dart';
import 'package:poke_dungeon/models/item_definition.dart';
import 'package:poke_dungeon/profile/player_profile.dart';
import 'package:poke_dungeon/profile/profile_state.dart';

import 'profile_test_fixtures.dart';

ProfileState richState({int coins = 0, int gems = 0}) =>
    ProfileState.fresh(testToday).copyWith(coins: coins, gems: gems);

void main() {
  group('fresh profile', () {
    test('starts with no currency at trainer level 1', () {
      final profile = buildProfile();

      expect(profile.coins, 0);
      expect(profile.gems, 0);
      expect(profile.trainerLevel, 1);
      expect(profile.xpIntoLevel, 0);
      expect(profile.xpForNextLevel, 100);
    });

    test('only unlocks the first chapter', () {
      final profile = buildProfile();

      expect(profile.highestUnlockedChapter, 1);
      expect(profile.isChapterCompleted(1), isFalse);
      expect(profile.bestRoomFor(1), 0);
    });

    test('owns and equips the silk scarf at level 1', () {
      final profile = buildProfile();

      expect(profile.owns(ItemCatalog.silkScarf), isTrue);
      expect(profile.levelOf(ItemCatalog.silkScarf), 1);
      expect(profile.isEquipped(ItemCatalog.silkScarf), isTrue);
      expect(
        profile.equipped[EquipmentSlot.attack]?.item,
        ItemCatalog.silkScarf,
      );
      expect(profile.ownedEquipment, hasLength(1));
    });

    test('holds two potions', () {
      expect(buildProfile().consumables, {ItemCatalog.potion: 2});
    });

    test('offers three daily quests', () {
      expect(buildProfile().dailyQuests, hasLength(3));
    });
  });

  group('applyRunResult', () {
    test('adds earned coins', () {
      final profile = buildProfile()
        ..applyRunResult(buildRunResult(coinsEarned: 140));

      expect(profile.coins, 140);
    });

    test('grants xp from rooms, bosses, victory and enemies', () {
      final profile = buildProfile()
        ..applyRunResult(buildRunResult(roomsCleared: 2, enemiesDefeated: 10));

      expect(profile.trainerLevel, 1);
      expect(profile.xpIntoLevel, 2 * 20 + 10 * 2);
    });

    test('overflows several trainer levels at once', () {
      final profile = buildProfile()
        ..applyRunResult(
          buildRunResult(
            roomsCleared: 10,
            bossesDefeated: 2,
            isVictory: true,
            enemiesDefeated: 15,
          ),
        );

      final totalXp = 10 * 20 + 2 * 60 + 250 + 15 * 2;
      expect(totalXp, 600);
      expect(profile.trainerLevel, 4);
      expect(profile.xpIntoLevel, 600 - 100 - 160 - 220);
    });

    test('keeps the best room reached per chapter', () {
      final profile = buildProfile()
        ..applyRunResult(buildRunResult(roomsCleared: 6))
        ..applyRunResult(buildRunResult(roomsCleared: 3));

      expect(profile.bestRoomFor(1), 6);
    });

    test('a defeat does not unlock the next chapter', () {
      final profile = buildProfile()
        ..applyRunResult(buildRunResult(roomsCleared: 9));

      expect(profile.highestUnlockedChapter, 1);
      expect(profile.isChapterCompleted(1), isFalse);
    });

    test('a victory completes the chapter and unlocks the next one', () {
      final profile = buildProfile()
        ..applyRunResult(buildRunResult(roomsCleared: 10, isVictory: true));

      expect(profile.isChapterCompleted(1), isTrue);
      expect(profile.highestUnlockedChapter, 2);
    });

    test('replaying an earlier chapter never lowers the unlocked chapter', () {
      final profile = buildProfile(
        state: ProfileState.fresh(testToday)
            .copyWith(highestUnlockedChapter: 4),
      )..applyRunResult(buildRunResult(chapterNumber: 1, isVictory: true));

      expect(profile.highestUnlockedChapter, 4);
    });

    test('winning the last chapter keeps the unlock capped', () {
      final lastChapter = ChapterCatalog.all.length;
      final profile =
          buildProfile(
            state: ProfileState.fresh(testToday)
                .copyWith(highestUnlockedChapter: lastChapter),
          )..applyRunResult(
            buildRunResult(chapterNumber: lastChapter, isVictory: true),
          );

      expect(profile.highestUnlockedChapter, lastChapter);
      expect(profile.isChapterCompleted(lastChapter), isTrue);
    });

    test('adds newly found equipment at level 1', () {
      final profile = buildProfile()
        ..applyRunResult(
          buildRunResult(foundEquipment: [ItemCatalog.muscleBand]),
        );

      expect(profile.owns(ItemCatalog.muscleBand), isTrue);
      expect(profile.levelOf(ItemCatalog.muscleBand), 1);
    });

    test('auto equips found equipment only into an empty slot', () {
      final profile = buildProfile()
        ..applyRunResult(
          buildRunResult(
            foundEquipment: [ItemCatalog.muscleBand, ItemCatalog.hardStone],
          ),
        );

      expect(profile.isEquipped(ItemCatalog.silkScarf), isTrue);
      expect(profile.isEquipped(ItemCatalog.hardStone), isTrue);
    });

    test('converts already owned equipment into half its price in coins', () {
      final profile = buildProfile()
        ..applyRunResult(
          buildRunResult(
            foundEquipment: [ItemCatalog.muscleBand, ItemCatalog.muscleBand],
          ),
        );

      expect(profile.coins, ItemCatalog.muscleBand.price ~/ 2);
      expect(profile.levelOf(ItemCatalog.muscleBand), 1);
    });

    test('a duplicate free item gives nothing', () {
      final profile = buildProfile()
        ..applyRunResult(
          buildRunResult(foundEquipment: [ItemCatalog.silkScarf]),
        );

      expect(profile.coins, 0);
    });

    test('replaces the consumable stock with the unused consumables', () {
      final profile = buildProfile()
        ..applyRunResult(
          buildRunResult(
            unusedConsumables: {ItemCatalog.potion: 0, ItemCatalog.xSpeed: 1},
          ),
        );

      expect(profile.consumables, {ItemCatalog.xSpeed: 1});
    });

    test('notifies listeners and saves', () {
      final storage = InMemoryProfileStorage();
      var notificationCount = 0;
      buildProfile(storage: storage)
        ..addListener(() => notificationCount++)
        ..applyRunResult(buildRunResult(coinsEarned: 10));

      expect(notificationCount, 1);
      expect(storage.writeCount, 1);
    });
  });

  group('prepareRun', () {
    test('builds the run config from the loadout and consumable stock', () {
      final profile = buildProfile();

      final config = profile.prepareRun(1);

      expect(config.chapter, ChapterCatalog.byNumber(1));
      expect(
        config.loadout.equipped[EquipmentSlot.attack]?.item,
        ItemCatalog.silkScarf,
      );
      expect(config.loadout.equipped[EquipmentSlot.attack]?.level, 1);
      expect(config.startingConsumables, {ItemCatalog.potion: 2});
    });

    test('carries upgraded levels into the loadout', () {
      final profile = buildProfile(state: richState(coins: 1000))
        ..upgrade(ItemCatalog.silkScarf);

      expect(
        profile.prepareRun(1).loadout.equipped[EquipmentSlot.attack]?.level,
        2,
      );
    });

    test('refuses a locked chapter', () {
      final profile = buildProfile();

      expect(
        () => profile.prepareRun(2),
        throwsA(isA<ChapterLockedException>()),
      );
      expect(
        () => profile.prepareRun(0),
        throwsA(isA<ChapterLockedException>()),
      );
    });
  });

  group('equipment', () {
    test('equipping an owned item replaces the item in its slot', () {
      final profile = buildProfile()
        ..applyRunResult(buildRunResult(foundEquipment: [ItemCatalog.charcoal]))
        ..equip(ItemCatalog.charcoal);

      expect(profile.isEquipped(ItemCatalog.charcoal), isTrue);
      expect(profile.isEquipped(ItemCatalog.silkScarf), isFalse);
    });

    test('equipping an item not owned is ignored', () {
      final profile = buildProfile()..equip(ItemCatalog.lifeOrb);

      expect(profile.isEquipped(ItemCatalog.lifeOrb), isFalse);
      expect(profile.isEquipped(ItemCatalog.silkScarf), isTrue);
    });

    test('unequipping empties the slot but keeps ownership', () {
      final profile = buildProfile()..unequip(EquipmentSlot.attack);

      expect(profile.equipped, isEmpty);
      expect(profile.loadout.equipped, isEmpty);
      expect(profile.owns(ItemCatalog.silkScarf), isTrue);
    });

    test('levelOf an item not owned is zero', () {
      expect(buildProfile().levelOf(ItemCatalog.lifeOrb), 0);
    });
  });

  group('upgrade', () {
    test('spends the upgrade cost and raises the level', () {
      final profile = buildProfile(state: richState(coins: 500));

      final result = profile.upgrade(ItemCatalog.silkScarf);

      expect(result, UpgradeResult.upgraded);
      expect(profile.levelOf(ItemCatalog.silkScarf), 2);
      expect(profile.coins, 500 - ItemCatalog.silkScarf.upgradeCost(1));
    });

    test('cost grows with the current level', () {
      final profile = buildProfile(state: richState(coins: 1000))
        ..upgrade(ItemCatalog.silkScarf)
        ..upgrade(ItemCatalog.silkScarf);

      final spent =
          ItemCatalog.silkScarf.upgradeCost(1) +
          ItemCatalog.silkScarf.upgradeCost(2);
      expect(profile.coins, 1000 - spent);
      expect(profile.levelOf(ItemCatalog.silkScarf), 3);
    });

    test('fails without enough coins', () {
      final profile = buildProfile();

      expect(
        profile.upgrade(ItemCatalog.silkScarf),
        UpgradeResult.notEnoughCoins,
      );
      expect(profile.levelOf(ItemCatalog.silkScarf), 1);
    });

    test('fails on an item not owned', () {
      expect(
        buildProfile(state: richState(coins: 1000))
            .upgrade(ItemCatalog.lifeOrb),
        UpgradeResult.notOwned,
      );
    });

    test('stops at the max level', () {
      final profile = buildProfile(state: richState(coins: 100000));
      for (var level = 1; level < EquipmentItem.maxLevel; level++) {
        expect(profile.upgrade(ItemCatalog.silkScarf), UpgradeResult.upgraded);
      }
      final coinsAtMaxLevel = profile.coins;

      expect(
        profile.upgrade(ItemCatalog.silkScarf),
        UpgradeResult.maxLevelReached,
      );
      expect(profile.levelOf(ItemCatalog.silkScarf), EquipmentItem.maxLevel);
      expect(profile.coins, coinsAtMaxLevel);
    });
  });

  group('buy', () {
    test('buying equipment spends its price and adds it at level 1', () {
      final profile = buildProfile(state: richState(coins: 200));

      expect(profile.buy(ItemCatalog.charcoal), ShopPurchaseResult.purchased);
      expect(profile.coins, 200 - ItemCatalog.charcoal.price);
      expect(profile.levelOf(ItemCatalog.charcoal), 1);
    });

    test('buying owned equipment is refused without spending', () {
      final profile = buildProfile(state: richState(coins: 200))
        ..buy(ItemCatalog.charcoal);

      expect(
        profile.buy(ItemCatalog.charcoal),
        ShopPurchaseResult.alreadyOwned,
      );
      expect(profile.coins, 200 - ItemCatalog.charcoal.price);
    });

    test('buying consumables stacks them', () {
      final profile = buildProfile(state: richState(coins: 100))
        ..buy(ItemCatalog.potion)
        ..buy(ItemCatalog.potion);

      expect(profile.consumables[ItemCatalog.potion], 4);
      expect(profile.coins, 100 - 2 * ItemCatalog.potion.price);
    });

    test('buying without enough coins is refused', () {
      final profile = buildProfile(state: richState(coins: 10));

      expect(
        profile.buy(ItemCatalog.potion),
        ShopPurchaseResult.notEnoughCoins,
      );
      expect(
        profile.buy(ItemCatalog.lifeOrb),
        ShopPurchaseResult.notEnoughCoins,
      );
      expect(profile.coins, 10);
      expect(profile.consumables[ItemCatalog.potion], 2);
    });
  });

  group('openChest', () {
    test('returns null and keeps gems when gems are missing', () {
      final profile = buildProfile(state: richState(gems: 99));

      expect(profile.openChest(), isNull);
      expect(profile.gems, 99);
    });

    test('spends gems and adds a new item from the rolled rarity', () {
      final profile = buildProfile(
        state: richState(gems: 250),
        random: ScriptedRandom([99, 1]),
      );

      final item = profile.openChest();

      expect(item, ItemCatalog.assaultVest);
      expect(item?.rarity, ItemRarity.legendary);
      expect(profile.gems, 250 - PlayerProfile.chestGemCost);
      expect(profile.levelOf(ItemCatalog.assaultVest), 1);
    });

    test('an already owned item gains a free level', () {
      final profile = buildProfile(
        state: richState(gems: 100),
        random: ScriptedRandom([0, 0]),
      );

      expect(profile.openChest(), ItemCatalog.silkScarf);
      expect(profile.levelOf(ItemCatalog.silkScarf), 2);
      expect(profile.gems, 0);
    });

    test('an owned item already at max level stays at max level', () {
      final maxedState = richState(gems: 100)
          .withEquipmentLevel(ItemCatalog.silkScarf, EquipmentItem.maxLevel);
      final profile = buildProfile(
        state: maxedState,
        random: ScriptedRandom([0, 0]),
      )..openChest();

      expect(profile.levelOf(ItemCatalog.silkScarf), EquipmentItem.maxLevel);
    });

    test('rarity rolls follow the 50/30/15/5 weights', () {
      final rarityByTicket = {
        0: ItemRarity.common,
        49: ItemRarity.common,
        50: ItemRarity.rare,
        79: ItemRarity.rare,
        80: ItemRarity.epic,
        94: ItemRarity.epic,
        95: ItemRarity.legendary,
        99: ItemRarity.legendary,
      };
      for (final rarityTicket in rarityByTicket.entries) {
        final profile = buildProfile(
          state: richState(gems: 100),
          random: ScriptedRandom([rarityTicket.key, 0]),
        );

        expect(profile.openChest()?.rarity, rarityTicket.value);
      }
    });
  });
}
