import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/components/enemy.dart';
import 'package:poke_dungeon/game/dungeon_game.dart';
import 'package:poke_dungeon/game/heroes/hero_catalog.dart';
import 'package:poke_dungeon/models/hero_definition.dart';

import 'fake_poke_api_service.dart';

const frameDuration = Duration(milliseconds: 50);
const maxFramesPerStep = 400;
Widget gameWidgetFor(DungeonGame game) => Directionality(
  textDirection: TextDirection.ltr,
  child: GameWidget<DungeonGame>(
    game: game,
    initialActiveOverlays: const [DungeonGame.hudOverlay],
    overlayBuilderMap: {
      for (final overlay in [
        DungeonGame.hudOverlay,
        DungeonGame.inventoryOverlay,
        DungeonGame.skillChoiceOverlay,
        DungeonGame.pauseOverlay,
        DungeonGame.runSummaryOverlay,
      ])
        overlay: (context, game) => const SizedBox.shrink(),
    },
  ),
);

Iterable<Enemy> livingEnemies(DungeonGame game) =>
    game.world.children.whereType<Enemy>().where((enemy) => !enemy.isDefeated);

Future<void> pumpUntil(WidgetTester tester, bool Function() condition) async {
  for (var frame = 0; frame < maxFramesPerStep; frame++) {
    if (condition()) {
      return;
    }
    await tester.pump(frameDuration);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  }
  fail('Condition never reached');
}

Future<DungeonGame> startGame(
  WidgetTester tester,
  FakePokeApiService api, {
  HeroDefinition hero = HeroCatalog.trainer,
}) async {
  final game = DungeonGame(
    config: chapterOneConfig(hero: hero),
    api: api,
    clock: () => DateTime(2026, 10, 5),
  );
  await tester.runAsync(() => game.loadMonsterSprite(spriteUrl));
  await tester.pumpWidget(gameWidgetFor(game));
  return game;
}

Future<void> clearCurrentRoom(WidgetTester tester, DungeonGame game) async {
  await pumpUntil(tester, () => livingEnemies(game).isNotEmpty);
  for (final enemy in livingEnemies(game).toList()) {
    enemy.takeDamage(enemy.hp);
  }
}
