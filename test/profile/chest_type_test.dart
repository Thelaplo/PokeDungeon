import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/items/item_catalog.dart';
import 'package:poke_dungeon/models/item_definition.dart';
import 'package:poke_dungeon/profile/player_profile.dart';
import 'package:poke_dungeon/profile/profile_state.dart';

import 'profile_test_fixtures.dart';

ProfileState stateWithGems(int gems) =>
    ProfileState.fresh(testToday).copyWith(gems: gems);

ItemRarity? hyperBallRarityForTicket(int ticket) => buildProfile(
  state: stateWithGems(ChestType.hyperBall.gemCost),
  random: ScriptedRandom([ticket, 0]),
).openChest(type: ChestType.hyperBall)?.rarity;

void main() {
  test('chest types expose their label and gem cost', () {
    expect(ChestType.pokeBall.label, 'Poké Ball');
    expect(ChestType.pokeBall.gemCost, 100);
    expect(ChestType.hyperBall.label, 'Hyper Ball');
    expect(ChestType.hyperBall.gemCost, 300);
  });

  test('legacy chest cost matches the poke ball cost', () {
    expect(PlayerProfile.chestGemCost, ChestType.pokeBall.gemCost);
  });

  test('opening without a type opens a poke ball', () {
    final profile = buildProfile(
      state: stateWithGems(ChestType.hyperBall.gemCost),
    );

    expect(profile.openChest(), isNotNull);
    expect(
      profile.gems,
      ChestType.hyperBall.gemCost - ChestType.pokeBall.gemCost,
    );
  });

  test('a hyper ball spends its gem cost', () {
    final profile = buildProfile(state: stateWithGems(350));

    expect(profile.openChest(type: ChestType.hyperBall), isNotNull);
    expect(profile.gems, 50);
  });

  test('a hyper ball without enough gems returns null and spends nothing', () {
    final profile = buildProfile(state: stateWithGems(299));

    expect(profile.canOpen(ChestType.hyperBall), isFalse);
    expect(profile.canOpen(ChestType.pokeBall), isTrue);
    expect(profile.openChest(type: ChestType.hyperBall), isNull);
    expect(profile.gems, 299);
  });

  test('canOpenChest still reflects the poke ball cost', () {
    expect(buildProfile(state: stateWithGems(99)).canOpenChest, isFalse);
    expect(buildProfile(state: stateWithGems(100)).canOpenChest, isTrue);
  });

  test('hyper ball rarity rolls follow the 0/55/35/10 weights', () {
    expect(hyperBallRarityForTicket(0), ItemRarity.rare);
    expect(hyperBallRarityForTicket(54), ItemRarity.rare);
    expect(hyperBallRarityForTicket(55), ItemRarity.epic);
    expect(hyperBallRarityForTicket(89), ItemRarity.epic);
    expect(hyperBallRarityForTicket(90), ItemRarity.legendary);
    expect(hyperBallRarityForTicket(99), ItemRarity.legendary);
  });

  test('a hyper ball never returns a common item', () {
    final profile = buildProfile(
      state: stateWithGems(ChestType.hyperBall.gemCost * 200),
      random: Random(42),
    );

    for (var opening = 0; opening < 200; opening++) {
      final item = profile.openChest(type: ChestType.hyperBall);
      expect(item?.rarity, isNot(ItemRarity.common));
    }
  });

  test('a duplicate from a hyper ball gains a free level', () {
    final profile = buildProfile(
      state: stateWithGems(ChestType.hyperBall.gemCost)
          .withNewEquipment(ItemCatalog.muscleBand),
      random: ScriptedRandom([0, 0]),
    );

    expect(
      profile.openChest(type: ChestType.hyperBall),
      ItemCatalog.muscleBand,
    );
    expect(profile.levelOf(ItemCatalog.muscleBand), 2);
  });
}
