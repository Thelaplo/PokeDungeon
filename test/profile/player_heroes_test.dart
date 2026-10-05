import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/heroes/hero_catalog.dart';
import 'package:poke_dungeon/profile/player_profile.dart';
import 'package:poke_dungeon/profile/profile_state.dart';
import 'package:poke_dungeon/profile/profile_storage.dart';
import 'package:poke_dungeon/profile/trainer_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_test_fixtures.dart';

ProfileState stateWith({int gems = 0, int trainerLevel = 1}) =>
    ProfileState.fresh(testToday).copyWith(
      gems: gems,
      trainer: TrainerProgress(level: trainerLevel, xpIntoLevel: 0),
    );

final bulbasaurPrice = HeroCatalog.bulbasaur.unlock.value;

void main() {
  group('unlock rules', () {
    test('a fresh profile has only the trainer unlocked and selected', () {
      final profile = buildProfile();

      expect(profile.selectedHero, HeroCatalog.trainer);
      expect(HeroCatalog.all.where(profile.isHeroUnlocked), [
        HeroCatalog.trainer,
      ]);
      expect(profile.newlyUnlockedHeroes, isEmpty);
    });

    test('a trainer level hero unlocks once the level is reached', () {
      expect(
        buildProfile(state: stateWith(trainerLevel: 2))
            .isHeroUnlocked(HeroCatalog.pikachu),
        isFalse,
      );
      expect(
        buildProfile(state: stateWith(trainerLevel: 3))
            .isHeroUnlocked(HeroCatalog.pikachu),
        isTrue,
      );
    });

    test('a chapter hero unlocks when that chapter is completed', () {
      final profile = buildProfile();
      expect(profile.isHeroUnlocked(HeroCatalog.charmander), isFalse);

      profile.applyRunResult(buildRunResult(chapterNumber: 1, isVictory: true));

      expect(profile.isHeroUnlocked(HeroCatalog.charmander), isTrue);
      expect(profile.isHeroUnlocked(HeroCatalog.eevee), isFalse);
    });

    test('a gem hero stays locked until purchased', () {
      final profile = buildProfile(state: stateWith(gems: 10000));

      expect(profile.isHeroUnlocked(HeroCatalog.bulbasaur), isFalse);
    });
  });

  group('buyHero', () {
    test('buying a gem hero spends gems and unlocks it', () {
      final profile = buildProfile(state: stateWith(gems: bulbasaurPrice + 5));

      expect(profile.canBuyHero(HeroCatalog.bulbasaur), isTrue);
      expect(
        profile.buyHero(HeroCatalog.bulbasaur),
        HeroPurchaseResult.purchased,
      );
      expect(profile.gems, 5);
      expect(profile.isHeroUnlocked(HeroCatalog.bulbasaur), isTrue);
      expect(profile.newlyUnlockedHeroes, isEmpty);
    });

    test('buying without enough gems is refused', () {
      final profile = buildProfile(state: stateWith(gems: bulbasaurPrice - 1));

      expect(profile.canBuyHero(HeroCatalog.bulbasaur), isFalse);
      expect(
        profile.buyHero(HeroCatalog.bulbasaur),
        HeroPurchaseResult.notEnoughGems,
      );
      expect(profile.gems, bulbasaurPrice - 1);
    });

    test('buying an already unlocked hero is refused', () {
      final profile = buildProfile(state: stateWith(gems: bulbasaurPrice * 2))
        ..buyHero(HeroCatalog.bulbasaur);

      expect(profile.canBuyHero(HeroCatalog.bulbasaur), isFalse);
      expect(
        profile.buyHero(HeroCatalog.bulbasaur),
        HeroPurchaseResult.alreadyUnlocked,
      );
      expect(profile.gems, bulbasaurPrice);
    });

    test('heroes unlocked by progression are not for sale', () {
      final profile = buildProfile(state: stateWith(gems: 10000));

      expect(profile.canBuyHero(HeroCatalog.pikachu), isFalse);
      expect(
        profile.buyHero(HeroCatalog.pikachu),
        HeroPurchaseResult.notForSale,
      );
      expect(
        profile.buyHero(HeroCatalog.trainer),
        HeroPurchaseResult.alreadyUnlocked,
      );
      expect(profile.gems, 10000);
    });
  });

  group('selectHero', () {
    test('selecting an unlocked hero changes the run hero', () {
      final profile = buildProfile(state: stateWith(trainerLevel: 3))
        ..selectHero(HeroCatalog.pikachu);

      expect(profile.selectedHero, HeroCatalog.pikachu);
      expect(profile.prepareRun(1).hero, HeroCatalog.pikachu);
    });

    test('selecting a locked hero is ignored', () {
      final profile = buildProfile()..selectHero(HeroCatalog.mewtwo);

      expect(profile.selectedHero, HeroCatalog.trainer);
      expect(profile.prepareRun(1).hero, HeroCatalog.trainer);
    });

    test('selecting notifies listeners', () {
      var notificationCount = 0;
      buildProfile(state: stateWith(trainerLevel: 3))
        ..addListener(() => notificationCount++)
        ..selectHero(HeroCatalog.pikachu);

      expect(notificationCount, 1);
    });
  });

  group('newly unlocked heroes', () {
    test('heroes unlocked by a run are reported until acknowledged', () {
      final profile = buildProfile()
        ..applyRunResult(
          buildRunResult(
            chapterNumber: 1,
            isVictory: true,
            roomsCleared: 10,
            bossesDefeated: 2,
          ),
        );

      expect(profile.trainerLevel, greaterThanOrEqualTo(3));
      expect(
        profile.newlyUnlockedHeroes,
        containsAll([HeroCatalog.pikachu, HeroCatalog.charmander]),
      );

      profile.acknowledgeHeroes();

      expect(profile.newlyUnlockedHeroes, isEmpty);
    });

    test('acknowledging with nothing new does not notify', () {
      var notificationCount = 0;
      buildProfile()
        ..addListener(() => notificationCount++)
        ..acknowledgeHeroes();

      expect(notificationCount, 0);
    });
  });

  group('persistence', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<PlayerProfile> loadProfile() =>
        PlayerProfile.load(clock: () => testToday);

    test(
      'selected, purchased and acknowledged heroes survive a reload',
      () async {
        final original = await loadProfile()
          ..applyRunResult(buildRunResult(chapterNumber: 1, isVictory: true))
          ..acknowledgeHeroes()
          ..selectHero(HeroCatalog.charmander);
        final storage = await SharedPreferencesProfileStorage.create();
        final saved = jsonDecode(storage.read()!) as Map<String, Object?>;
        saved['gems'] = bulbasaurPrice;
        await storage.write(jsonEncode(saved));
        final withGems = await loadProfile()
          ..buyHero(HeroCatalog.bulbasaur);
        await withGems.save();

        final reloaded = await loadProfile();

        expect(original.selectedHero, HeroCatalog.charmander);
        expect(reloaded.selectedHero, HeroCatalog.charmander);
        expect(reloaded.isHeroUnlocked(HeroCatalog.bulbasaur), isTrue);
        expect(reloaded.newlyUnlockedHeroes, isEmpty);
        expect(reloaded.gems, 0);
      },
    );

    test('unknown hero ids fall back to the trainer and are dropped', () async {
      final original = await loadProfile();
      await original.save();
      final storage = await SharedPreferencesProfileStorage.create();
      final saved = jsonDecode(storage.read()!) as Map<String, Object?>;
      saved['selectedHero'] = 'missingno';
      saved['purchasedHeroes'] = ['missingno', 'bulbasaur'];
      await storage.write(jsonEncode(saved));

      final reloaded = await loadProfile();

      expect(reloaded.selectedHero, HeroCatalog.trainer);
      expect(reloaded.isHeroUnlocked(HeroCatalog.bulbasaur), isTrue);
    });

    test(
      'a selected hero that is no longer unlocked falls back to the trainer',
      () async {
        final original = await loadProfile();
        await original.save();
        final storage = await SharedPreferencesProfileStorage.create();
        final saved = jsonDecode(storage.read()!) as Map<String, Object?>;
        saved['selectedHero'] = HeroCatalog.mewtwo.id;
        await storage.write(jsonEncode(saved));

        expect((await loadProfile()).selectedHero, HeroCatalog.trainer);
      },
    );

    test('a save without hero fields loads with the trainer', () async {
      final original = await loadProfile();
      await original.save();
      final storage = await SharedPreferencesProfileStorage.create();
      final saved = jsonDecode(storage.read()!) as Map<String, Object?>
        ..remove('selectedHero')
        ..remove('purchasedHeroes')
        ..remove('acknowledgedHeroes');
      await storage.write(jsonEncode(saved));

      final reloaded = await loadProfile();

      expect(reloaded.selectedHero, HeroCatalog.trainer);
      expect(reloaded.newlyUnlockedHeroes, isEmpty);
    });
  });
}
