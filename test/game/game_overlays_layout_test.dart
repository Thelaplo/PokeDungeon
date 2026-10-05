import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/components/enemy.dart';
import 'package:poke_dungeon/game/dungeon_game.dart';
import 'package:poke_dungeon/game/heroes/hero_catalog.dart';
import 'package:poke_dungeon/models/hero_definition.dart';
import 'package:poke_dungeon/ui/game/game_screen.dart';
import 'package:poke_dungeon/ui/game/skill_choice/skill_card.dart';

import 'support/fake_poke_api_service.dart';

const phoneSize = Size(375, 812);
const tabletSize = Size(1024, 768);
const maxFrames = 400;

Future<DungeonGame> openGameScreen(
  WidgetTester tester, {
  required Size screenSize,
  required HeroDefinition hero,
}) async {
  tester.view
    ..physicalSize = screenSize
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: GameScreen(
        config: chapterOneConfig(hero: hero),
        api: FakePokeApiService(),
      ),
    ),
  );
  await tester.pump();
  final game = tester
      .widget<GameWidget<DungeonGame>>(find.byType(GameWidget<DungeonGame>))
      .game!;
  await tester.runAsync(() => game.loadMonsterSprite(spriteUrl));
  return game;
}

Future<void> pumpUntilTrue(
  WidgetTester tester,
  bool Function() condition,
) async {
  for (var frame = 0; frame < maxFrames; frame++) {
    if (condition()) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  }
  fail('Condition never reached');
}

Iterable<Enemy> livingEnemiesOf(DungeonGame game) =>
    game.world.children.whereType<Enemy>().where((enemy) => !enemy.isDefeated);

Future<void> walkThroughEveryOverlay(
  WidgetTester tester, {
  required Size screenSize,
  required HeroDefinition hero,
  required int expectedSkillCards,
}) async {
  final game = await openGameScreen(tester, screenSize: screenSize, hero: hero);
  await pumpUntilTrue(tester, () => livingEnemiesOf(game).isNotEmpty);
  expect(find.text('Sac'), findsOneWidget);

  game.openInventory();
  await tester.pump();
  expect(find.text('Équipement'), findsOneWidget);
  await tester.tap(find.text('Objets'));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
  expect(find.text('Utiliser'), findsOneWidget);
  game.closeInventory();
  await tester.pump();

  for (final enemy in livingEnemiesOf(game).toList()) {
    enemy.takeDamage(enemy.hp);
  }
  await pumpUntilTrue(
    tester,
    () => game.overlays.isActive(DungeonGame.skillChoiceOverlay),
  );
  await tester.pump();
  expect(find.byType(SkillCard), findsNWidgets(expectedSkillCards));
  await tester.tap(find.byType(SkillCard).first);
  await tester.pump();

  game.openPauseMenu();
  await tester.pump();
  expect(find.text('Reprendre'), findsOneWidget);
  await tester.tap(find.text('Abandonner'));
  await tester.pump();
  expect(find.text('Défaite'), findsOneWidget);
  expect(find.text('Continuer'), findsOneWidget);

  await tester.pumpWidget(const SizedBox.shrink());
}

void main() {
  testWidgets('every in-run overlay fits a phone screen', (tester) async {
    await walkThroughEveryOverlay(
      tester,
      screenSize: phoneSize,
      hero: HeroCatalog.trainer,
      expectedSkillCards: 3,
    );
  });

  testWidgets('Évoli gets four skill cards on a phone screen', (tester) async {
    await walkThroughEveryOverlay(
      tester,
      screenSize: phoneSize,
      hero: HeroCatalog.eevee,
      expectedSkillCards: 4,
    );
  });

  testWidgets('every in-run overlay fits a tablet screen', (tester) async {
    await walkThroughEveryOverlay(
      tester,
      screenSize: tabletSize,
      hero: HeroCatalog.squirtle,
      expectedSkillCards: 3,
    );
  });
}
