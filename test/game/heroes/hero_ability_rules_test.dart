import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/heroes/hero_ability_rules.dart';
import 'package:poke_dungeon/game/heroes/hero_catalog.dart';
import 'package:poke_dungeon/game/items/item_catalog.dart';
import 'package:poke_dungeon/game/skills/run_skills.dart';
import 'package:poke_dungeon/models/hero_definition.dart';
import 'package:poke_dungeon/models/player_stats.dart';
import 'package:poke_dungeon/models/run_config.dart';

Vector2 positionOf(Vector2 point) => point;

void main() {
  group('chain lightning', () {
    test('only Pikachu chains', () {
      expect(HeroAbilityRules.canChain(HeroCatalog.pikachu.ability), isTrue);
      expect(HeroAbilityRules.canChain(HeroAbility.none), isFalse);
      expect(HeroAbilityRules.canChain(HeroAbility.burn), isFalse);
    });

    test('a bounce deals sixty percent of the hit', () {
      expect(HeroAbilityRules.chainDamage(20), 12);
      expect(HeroAbilityRules.chainDamage(1), 1);
    });

    test('the bounce targets the nearest candidate in range', () {
      final nearest = HeroAbilityRules.nearestWithin(
        origin: Vector2.zero(),
        candidates: [Vector2(150, 0), Vector2(0, 90), Vector2(30, 300)],
        positionOf: positionOf,
      );

      expect(nearest, Vector2(0, 90));
    });

    test('nothing out of range is targeted', () {
      final nearest = HeroAbilityRules.nearestWithin(
        origin: Vector2.zero(),
        candidates: [Vector2(221, 0), Vector2(0, -400)],
        positionOf: positionOf,
      );

      expect(nearest, isNull);
    });

    test('a candidate exactly at the range edge is targeted', () {
      final nearest = HeroAbilityRules.nearestWithin(
        origin: Vector2.zero(),
        candidates: [Vector2(HeroAbilityRules.chainRange, 0)],
        positionOf: positionOf,
      );

      expect(nearest, isNotNull);
    });
  });

  group('other abilities', () {
    test('only Salamèche burns', () {
      expect(
        HeroAbilityRules.appliesBurn(HeroCatalog.charmander.ability),
        isTrue,
      );
      expect(HeroAbilityRules.appliesBurn(HeroAbility.chainLightning), isFalse);
    });

    test('only Carapuce has a shield', () {
      expect(HeroAbilityRules.hasShield(HeroCatalog.squirtle.ability), isTrue);
      expect(HeroAbilityRules.hasShield(HeroAbility.leech), isFalse);
    });

    test('Bulbizarre heals on every defeat', () {
      expect(
        HeroAbilityRules.healOnDefeat(HeroCatalog.bulbasaur.ability),
        HeroAbilityRules.leechHealPerDefeat,
      );
      expect(HeroAbilityRules.healOnDefeat(HeroAbility.none), 0);
    });

    test('Évoli drafts four skills', () {
      expect(HeroAbilityRules.skillDraftSize(HeroCatalog.eevee.ability), 4);
      expect(
        HeroAbilityRules.skillDraftSize(HeroAbility.none),
        RunSkills.draftSize,
      );
    });

    test('a four card draft offers four different skills', () {
      final offer = RunSkills().draft(
        Random(2),
        isPlayerHurt: true,
        size: HeroAbilityRules.skillDraftSize(HeroAbility.adaptability),
      );

      expect(offer.toSet(), hasLength(4));
    });

    test('Mewtwo pierces every enemy', () {
      expect(
        HeroAbilityRules.projectilePiercing(HeroCatalog.mewtwo.ability, 1),
        HeroAbilityRules.unlimitedPiercing,
      );
      expect(HeroAbilityRules.projectilePiercing(HeroAbility.none, 2), 2);
    });
  });

  group('hero stats', () {
    test('hero modifiers stack with the equipment', () {
      final stats = PlayerStats.from([
        ...const EquipmentLoadout({}).modifiers,
        HeroCatalog.squirtle.modifiers,
        ItemCatalog.hardStone.modifiersAtLevel(1),
      ]);

      expect(stats.maxHp, PlayerStats.baseMaxHp + 20 + 20);
    });

    test('the trainer has no stat bonus', () {
      final stats = PlayerStats.from([HeroCatalog.trainer.modifiers]);

      expect(stats.maxHp, PlayerStats.baseMaxHp);
      expect(stats.damage, PlayerStats.baseDamage);
    });
  });
}
