import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/combat/cooldown_gate.dart';
import 'package:poke_dungeon/game/combat/type_damage.dart';
import 'package:poke_dungeon/game/components/combat_text.dart';
import 'package:poke_dungeon/game/components/enemy.dart';
import 'package:poke_dungeon/game/dungeon_game.dart';
import 'package:poke_dungeon/game/heroes/hero_catalog.dart';
import 'package:poke_dungeon/models/hero_definition.dart';
import 'package:poke_dungeon/models/pokemon_type.dart';

import 'support/fake_poke_api_service.dart';
import 'support/game_test_driver.dart';

Future<(DungeonGame, Enemy)> firstEnemyFacing(
  WidgetTester tester, {
  required HeroDefinition hero,
  required List<String> enemyTypes,
}) async {
  final game = await startGame(
    tester,
    FakePokeApiService(monsterTypes: enemyTypes),
    hero: hero,
  );
  await pumpUntil(tester, () => livingEnemies(game).isNotEmpty);
  return (game, livingEnemies(game).first);
}

Iterable<CombatText> combatTextsOf(DungeonGame game) =>
    game.world.children.whereType<CombatText>();

void main() {
  group('type chart', () {
    test('fire is super effective against grass', () {
      expect(TypeChart.multiplier(PokemonType.fire, [PokemonType.grass]), 2);
    });

    test('water is super effective against fire', () {
      expect(TypeChart.multiplier(PokemonType.water, [PokemonType.fire]), 2);
    });

    test('electric barely scratches ground', () {
      expect(
        TypeChart.multiplier(PokemonType.electric, [PokemonType.ground]),
        0.25,
      );
    });

    test('normal barely scratches ghost', () {
      expect(
        TypeChart.multiplier(PokemonType.normal, [PokemonType.ghost]),
        0.25,
      );
    });

    test('dual types multiply together', () {
      expect(
        TypeChart.multiplier(PokemonType.ice, [
          PokemonType.grass,
          PokemonType.flying,
        ]),
        4,
      );
      expect(
        TypeChart.multiplier(PokemonType.fire, [
          PokemonType.grass,
          PokemonType.water,
        ]),
        1,
      );
    });

    test('a multiplier maps to its effectiveness label', () {
      expect(TypeChart.effectivenessOf(2), TypeEffectiveness.superEffective);
      expect(TypeChart.effectivenessOf(1), TypeEffectiveness.neutral);
      expect(
        TypeChart.effectivenessOf(0.5),
        TypeEffectiveness.notVeryEffective,
      );
      expect(TypeChart.effectivenessOf(0.25), TypeEffectiveness.immune);
    });
  });

  group('type damage', () {
    test('unknown api types are ignored', () {
      expect(TypeDamage.parseTypes(['grass', 'shadow', 'poison']), [
        PokemonType.grass,
        PokemonType.poison,
      ]);
    });

    test('an enemy without known types takes neutral damage', () {
      expect(
        TypeDamage.heroAttackMultiplier(
          heroType: PokemonType.fire,
          enemyTypes: const [],
        ),
        1,
      );
    });

    test('scaled damage never drops below one', () {
      expect(TypeDamage.scale(10, 2), 20);
      expect(TypeDamage.scale(10, 0.25), 3);
      expect(TypeDamage.scale(1, 0.25), 1);
    });

    test('contact damage uses the enemy primary type only', () {
      expect(
        TypeDamage.enemyContactMultiplier(
          enemyTypes: const [PokemonType.fire, PokemonType.ground],
          heroType: PokemonType.water,
        ),
        0.5,
      );
      expect(
        TypeDamage.enemyContactMultiplier(
          enemyTypes: const [],
          heroType: PokemonType.water,
        ),
        1,
      );
    });

    test('effectiveness text is throttled per enemy', () {
      final gate = CooldownGate(interval: 0.6);

      expect(gate.tryPass(), isTrue);
      expect(gate.tryPass(), isFalse);
      gate.tick(0.6);
      expect(gate.tryPass(), isTrue);
    });
  });

  group('damage integration', () {
    testWidgets('Salamèche deals double damage to grass Pokémon', (
      tester,
    ) async {
      final (game, enemy) = await firstEnemyFacing(
        tester,
        hero: HeroCatalog.charmander,
        enemyTypes: const ['grass', 'poison'],
      );
      final hpBefore = enemy.hp;

      enemy.takeHeroHit(5);

      expect(hpBefore - enemy.hp, 10);
      await tester.pump(const Duration(milliseconds: 16));
      expect(combatTextsOf(game), hasLength(1));
      expect(
        combatTextsOf(game).first.effectiveness,
        TypeEffectiveness.superEffective,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('effectiveness text does not spam on rapid hits', (
      tester,
    ) async {
      final (game, enemy) = await firstEnemyFacing(
        tester,
        hero: HeroCatalog.charmander,
        enemyTypes: const ['bug'],
      );

      enemy
        ..takeHeroHit(1)
        ..takeHeroHit(1)
        ..takeHeroHit(1);
      await tester.pump(const Duration(milliseconds: 16));

      expect(combatTextsOf(game), hasLength(1));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('the trainer barely hurts ghost Pokémon', (tester) async {
      final (game, enemy) = await firstEnemyFacing(
        tester,
        hero: HeroCatalog.trainer,
        enemyTypes: const ['ghost'],
      );
      final hpBefore = enemy.hp;

      enemy.takeHeroHit(8);

      expect(hpBefore - enemy.hp, 2);
      await tester.pump(const Duration(milliseconds: 16));
      expect(combatTextsOf(game).first.effectiveness, TypeEffectiveness.immune);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('neutral hits show no effectiveness text', (tester) async {
      final (game, enemy) = await firstEnemyFacing(
        tester,
        hero: HeroCatalog.trainer,
        enemyTypes: const ['normal'],
      );
      final hpBefore = enemy.hp;

      enemy.takeHeroHit(8);

      expect(hpBefore - enemy.hp, 8);
      await tester.pump(const Duration(milliseconds: 16));
      expect(combatTextsOf(game), isEmpty);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('burn ticks inherit the type multiplier', (tester) async {
      final (_, enemy) = await firstEnemyFacing(
        tester,
        hero: HeroCatalog.charmander,
        enemyTypes: const ['grass'],
      );
      final hpBefore = enemy.hp;

      enemy.ignite(20);
      await pumpUntil(tester, () => enemy.hp < hpBefore);

      expect(hpBefore - enemy.hp, 6);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('fire Pokémon hit Carapuce for half damage', (tester) async {
      final (_, fireEnemy) = await firstEnemyFacing(
        tester,
        hero: HeroCatalog.squirtle,
        enemyTypes: const ['fire'],
      );
      final fireContactDamage = fireEnemy.contactDamage;
      await tester.pumpWidget(const SizedBox.shrink());
      final (_, normalEnemy) = await firstEnemyFacing(
        tester,
        hero: HeroCatalog.squirtle,
        enemyTypes: const ['normal'],
      );

      expect(fireContactDamage, (normalEnemy.contactDamage * 0.5).round());
      expect(fireContactDamage, lessThan(normalEnemy.contactDamage));

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
