import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/components/enemy.dart';
import 'package:poke_dungeon/game/components/projectile.dart';
import 'package:poke_dungeon/game/dungeon_game.dart';
import 'package:poke_dungeon/ui/game/game_screen.dart';

import 'support/fake_poke_api_service.dart';

const phoneSize = Size(375, 812);
const realFrame = Duration(milliseconds: 16);
const maxRealFrames = 900;
const throttledFrame = Duration(seconds: 2);
const throttledFrameCount = 20;

class LaunchButton extends StatelessWidget {
  const LaunchButton({required this.api, super.key});

  final FakePokeApiService api;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () =>
            Navigator.of(context)
                .push(GameScreen.route(config: chapterOneConfig(), api: api)),
        child: const Text('launch'),
      ),
    );
  }
}

Future<DungeonGame> launchFromHub(WidgetTester tester) async {
  tester.view
    ..physicalSize = phoneSize
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: LaunchButton(api: FakePokeApiService())),
    ),
  );
  await tester.tap(find.text('launch'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  return tester
      .widget<GameWidget<DungeonGame>>(find.byType(GameWidget<DungeonGame>))
      .game!;
}

Future<void> pumpRealFramesUntil(
  WidgetTester tester,
  bool Function() condition,
) async {
  for (var frame = 0; frame < maxRealFrames; frame++) {
    if (condition()) {
      return;
    }
    await tester.pump(realFrame);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  }
  fail('Condition never reached');
}

Iterable<Enemy> enemiesOf(DungeonGame game) =>
    game.world.children.whereType<Enemy>();

bool hasProjectiles(DungeonGame game) =>
    game.world.children.whereType<Projectile>().isNotEmpty;

bool hasHurtEnemy(DungeonGame game) =>
    enemiesOf(game).any((enemy) => enemy.hp < enemy.maxHp);

void main() {
  testWidgets('the hero auto-fires and hurts enemies after a hub launch', (
    tester,
  ) async {
    final game = await launchFromHub(tester);

    await pumpRealFramesUntil(tester, () => enemiesOf(game).isNotEmpty);
    await pumpRealFramesUntil(tester, () => hasProjectiles(game));
    await pumpRealFramesUntil(
      tester,
      () => hasHurtEnemy(game) || game.score.value > 0,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the hero still hits enemies when frames arrive seconds apart', (
    tester,
  ) async {
    final game = await launchFromHub(tester);
    await pumpRealFramesUntil(tester, () => enemiesOf(game).isNotEmpty);

    for (var frame = 0; frame < throttledFrameCount; frame++) {
      if (hasHurtEnemy(game)) {
        break;
      }
      await tester.pump(throttledFrame);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    }

    expect(hasHurtEnemy(game), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the space key reaches the game after a hub launch', (
    tester,
  ) async {
    final game = await launchFromHub(tester);
    await pumpRealFramesUntil(tester, () => game.player?.isMounted ?? false);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
    await pumpRealFramesUntil(tester, () => hasProjectiles(game));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.space);

    expect(enemiesOf(game), isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
