import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/dungeon_game.dart';
import 'package:poke_dungeon/models/run_result.dart';
import 'package:poke_dungeon/ui/game/game_screen.dart';

import 'support/fake_poke_api_service.dart';

class LauncherPage extends StatelessWidget {
  const LauncherPage({required this.api, required this.onResult, super.key});

  final FakePokeApiService api;
  final ValueChanged<RunResult?> onResult;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () async {
          final result = await Navigator.of(context)
              .push(GameScreen.route(config: chapterOneConfig(), api: api));
          onResult(result);
        },
        child: const Text('launch'),
      ),
    );
  }
}

DungeonGame runningGame(WidgetTester tester) => tester
    .widget<GameWidget<DungeonGame>>(find.byType(GameWidget<DungeonGame>))
    .game!;

Future<void> pumpFrames(WidgetTester tester, int frameCount) async {
  for (var frame = 0; frame < frameCount; frame++) {
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  }
}

void main() {
  testWidgets('back pauses the run and the route pops with a result', (
    tester,
  ) async {
    final api = FakePokeApiService();
    RunResult? poppedResult;
    var hasPopped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LauncherPage(
            api: api,
            onResult: (result) {
              hasPopped = true;
              poppedResult = result;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('launch'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final game = runningGame(tester);
    await tester.runAsync(() => game.loadMonsterSprite(spriteUrl));
    await pumpFrames(tester, 4);

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(game.isPauseMenuOpen, isTrue);
    expect(hasPopped, isFalse);

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(game.isPauseMenuOpen, isFalse);
    expect(hasPopped, isFalse);

    game.openPauseMenu();
    await tester.pump();
    game.abandonRun();
    await tester.pump();
    expect(hasPopped, isFalse);

    await tester.binding.handlePopRoute();
    await pumpFrames(tester, 10);

    expect(hasPopped, isTrue);
    expect(poppedResult, isNotNull);
    expect(poppedResult!.isVictory, isFalse);
    expect(poppedResult!.chapterNumber, 1);
    expect(api.isClosed, isFalse);
  });
}
