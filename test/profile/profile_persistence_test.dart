import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/items/item_catalog.dart';
import 'package:poke_dungeon/models/daily_quest.dart';
import 'package:poke_dungeon/models/item_definition.dart';
import 'package:poke_dungeon/profile/player_profile.dart';
import 'package:poke_dungeon/profile/profile_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_test_fixtures.dart';

Future<PlayerProfile> loadProfile({DateTime? today}) =>
    PlayerProfile.load(clock: () => today ?? testToday);

void expectFreshProfile(PlayerProfile profile) {
  expect(profile.coins, 0);
  expect(profile.trainerLevel, 1);
  expect(profile.highestUnlockedChapter, 1);
  expect(profile.isEquipped(ItemCatalog.silkScarf), isTrue);
  expect(profile.consumables, {ItemCatalog.potion: 2});
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('load without saved data returns a fresh profile', () async {
    expectFreshProfile(await loadProfile());
  });

  test('a profile survives a save and reload round trip', () async {
    final original = await loadProfile()
      ..applyRunResult(
        buildRunResult(
          roomsCleared: 10,
          isVictory: true,
          coinsEarned: 900,
          enemiesDefeated: 30,
          bossesDefeated: 2,
          foundEquipment: [ItemCatalog.hardStone],
          unusedConsumables: {ItemCatalog.xAttack: 1},
        ),
      )
      ..buy(ItemCatalog.charcoal)
      ..equip(ItemCatalog.charcoal)
      ..upgrade(ItemCatalog.charcoal)
      ..unequip(EquipmentSlot.accessory);
    await original.save();

    final reloaded = await loadProfile();

    expect(reloaded.coins, original.coins);
    expect(reloaded.gems, original.gems);
    expect(reloaded.trainerLevel, original.trainerLevel);
    expect(reloaded.xpIntoLevel, original.xpIntoLevel);
    expect(reloaded.highestUnlockedChapter, 2);
    expect(reloaded.isChapterCompleted(1), isTrue);
    expect(reloaded.bestRoomFor(1), 10);
    expect(reloaded.levelOf(ItemCatalog.charcoal), 2);
    expect(reloaded.levelOf(ItemCatalog.hardStone), 1);
    expect(reloaded.isEquipped(ItemCatalog.charcoal), isTrue);
    expect(reloaded.isEquipped(ItemCatalog.hardStone), isTrue);
    expect(reloaded.consumables, {ItemCatalog.xAttack: 1});
  });

  test('quest progress and claims survive a reload on the same day', () async {
    final original = await loadProfile()
      ..applyRunResult(
        buildRunResult(
          roomsCleared: 30,
          isVictory: true,
          coinsEarned: 1000,
          enemiesDefeated: 100,
          bossesDefeated: 5,
          isDailyEventDefeated: true,
          consumablesUsed: 5,
        ),
      );
    final claimedQuest = original.dailyQuests.firstWhere(
      (quest) => quest.canClaim,
    );
    original.claimQuest(claimedQuest.id);
    await original.save();

    final reloaded = await loadProfile(
      today: testToday.add(const Duration(hours: 3)),
    );

    expect(
      reloaded.dailyQuests.map((quest) => quest.progress),
      original.dailyQuests.map((quest) => quest.progress),
    );
    expect(
      reloaded.dailyQuests.firstWhere((quest) => quest.id == claimedQuest.id),
      isA<DailyQuest>().having((quest) => quest.isClaimed, 'isClaimed', true),
    );
    expect(reloaded.claimQuest(claimedQuest.id), isFalse);
  });

  test('saved quest progress is discarded on a new day', () async {
    final original = await loadProfile()
      ..applyRunResult(buildRunResult(enemiesDefeated: 100, roomsCleared: 30));
    await original.save();

    final reloaded = await loadProfile(
      today: testToday.add(const Duration(days: 1)),
    );

    expect(reloaded.dailyQuests.every((quest) => quest.progress == 0), isTrue);
    expect(reloaded.xpIntoLevel, isNot(0));
  });

  test('corrupt json falls back to a fresh profile', () async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesProfileStorage.storageKey: '{not json',
    });

    expectFreshProfile(await loadProfile());
  });

  test('json with wrong field types falls back to a fresh profile', () async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesProfileStorage.storageKey: jsonEncode({
        'version': 1,
        'coins': 'beaucoup',
      }),
    });

    expectFreshProfile(await loadProfile());
  });

  test('an unknown version falls back to a fresh profile', () async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesProfileStorage.storageKey: jsonEncode({
        'version': 999,
        'coins': 5000,
      }),
    });

    expectFreshProfile(await loadProfile());
  });

  test('unknown item ids are dropped when loading', () async {
    final original = await loadProfile();
    await original.save();
    final storage = await SharedPreferencesProfileStorage.create();
    final saved = jsonDecode(storage.read()!) as Map<String, Object?>;
    saved['equipmentLevels'] = {'silk-scarf': 3, 'ghost-item': 2};
    saved['consumables'] = {'potion': 1, 'ghost-potion': 4};
    await storage.write(jsonEncode(saved));

    final reloaded = await loadProfile();

    expect(reloaded.ownedEquipment, hasLength(1));
    expect(reloaded.levelOf(ItemCatalog.silkScarf), 3);
    expect(reloaded.consumables, {ItemCatalog.potion: 1});
  });
}
