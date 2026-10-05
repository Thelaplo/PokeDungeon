import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/components/projectile.dart';
import 'package:poke_dungeon/game/dungeon_game.dart';
import 'package:poke_dungeon/game/heroes/hero_ability_rules.dart';
import 'package:poke_dungeon/game/heroes/hero_catalog.dart';
import 'package:poke_dungeon/models/player_stats.dart';

import 'support/fake_poke_api_service.dart';
import 'support/game_test_driver.dart';

Iterable<Projectile> projectilesOf(DungeonGame game) =>
    game.world.children.whereType<Projectile>();

Future<void> endTest(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox.shrink());

void main() {
  testWidgets('the trainer keeps the room accent for its shots', (
    tester,
  ) async {
    final game = await startGame(tester, FakePokeApiService());
    await pumpUntil(tester, () => game.player?.isMounted ?? false);

    expect(game.projectileColor, game.room.theme.accentColor);
    expect(game.player!.size.x, lessThan(56));

    await endTest(tester);
  });

  testWidgets('a Pokémon hero shoots in its own color with its stats', (
    tester,
  ) async {
    final game = await startGame(
      tester,
      FakePokeApiService(),
      hero: HeroCatalog.pikachu,
    );
    await pumpUntil(tester, () => game.player?.isMounted ?? false);

    expect(game.projectileColor, HeroCatalog.pikachu.accentColor);
    expect(game.player!.stats.maxHp, PlayerStats.baseMaxHp - 10);
    expect(game.player!.size, Vector2.all(56));

    await endTest(tester);
  });

  testWidgets('Carapuce shrugs off the first contact hit', (tester) async {
    final game = await startGame(
      tester,
      FakePokeApiService(),
      hero: HeroCatalog.squirtle,
    );
    await pumpUntil(tester, () => game.player?.isMounted ?? false);
    final player = game.player!;
    final fullHp = player.hp;

    player.takeContactDamage(20);
    expect(player.hp, fullHp);
    expect(player.isShieldActive, isFalse);

    await pumpUntil(tester, () => !player.isInvulnerable);
    player.takeContactDamage(20);
    expect(player.hp, lessThan(fullHp));

    await endTest(tester);
  });

  testWidgets('Bulbizarre heals when a Pokémon is defeated', (tester) async {
    final game = await startGame(
      tester,
      FakePokeApiService(),
      hero: HeroCatalog.bulbasaur,
    );
    await pumpUntil(tester, () => livingEnemies(game).isNotEmpty);
    final player = game.player!..takeContactDamage(30);
    final hurtHp = player.hp;

    final enemy = livingEnemies(game).first;
    enemy.takeDamage(enemy.hp);

    expect(player.hp, hurtHp + HeroAbilityRules.leechHealPerDefeat);

    await endTest(tester);
  });

  testWidgets('Évoli is offered four skills', (tester) async {
    final game = await startGame(
      tester,
      FakePokeApiService(),
      hero: HeroCatalog.eevee,
    );

    await clearCurrentRoom(tester, game);
    await pumpUntil(
      tester,
      () => game.overlays.isActive(DungeonGame.skillChoiceOverlay),
    );

    expect(game.skillOffer, hasLength(4));

    await endTest(tester);
  });

  testWidgets('Salamèche burns enemies over time', (tester) async {
    final game = await startGame(
      tester,
      FakePokeApiService(),
      hero: HeroCatalog.charmander,
    );
    await pumpUntil(tester, () => livingEnemies(game).isNotEmpty);
    final enemy = livingEnemies(game).first;
    final hpBeforeBurn = enemy.hp;

    enemy.ignite(20);
    expect(enemy.isBurning, isTrue);
    await pumpUntil(tester, () => enemy.hp < hpBeforeBurn || enemy.isDefeated);

    expect(enemy.hp, lessThan(hpBeforeBurn));

    await endTest(tester);
  });

  testWidgets('Pikachu bounces a shot to a nearby enemy', (tester) async {
    final game = await startGame(
      tester,
      FakePokeApiService(),
      hero: HeroCatalog.pikachu,
    );
    await pumpUntil(tester, () => livingEnemies(game).length >= 2);
    final [source, target, ...] = livingEnemies(game).toList();
    target.position = source.position + Vector2(120, 0);

    game.spawnChainBounce(source: source, hitDamage: 10);
    await tester.pump(const Duration(milliseconds: 16));

    expect(
      projectilesOf(game).where(
        (projectile) =>
            projectile.damage == HeroAbilityRules.chainDamage(10) &&
            !projectile.canChain,
      ),
      isNotEmpty,
    );

    await endTest(tester);
  });

  testWidgets('Mewtwo shots pierce every enemy', (tester) async {
    final game = await startGame(
      tester,
      FakePokeApiService(),
      hero: HeroCatalog.mewtwo,
    );

    await pumpUntil(tester, () => projectilesOf(game).isNotEmpty);

    expect(
      projectilesOf(game).first.piercing,
      HeroAbilityRules.unlimitedPiercing,
    );

    await endTest(tester);
  });
}
