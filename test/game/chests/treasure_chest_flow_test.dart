import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/components/treasure_chest.dart';
import 'package:poke_dungeon/game/dungeon_game.dart';

import '../support/fake_poke_api_service.dart';
import '../support/game_test_driver.dart';

const chestRoom = 3;
const waitingFrames = 60;

Iterable<TreasureChest> chestsOf(DungeonGame game) =>
    game.world.children.whereType<TreasureChest>();

Future<void> clearRoomAndChooseSkill(
  WidgetTester tester,
  DungeonGame game,
) async {
  await clearCurrentRoom(tester, game);
  await pumpUntil(
    tester,
    () => game.overlays.isActive(DungeonGame.skillChoiceOverlay),
  );
  game.chooseSkill(game.skillOffer.first);
}

void main() {
  testWidgets('room 3 drops a chest that blocks the next room until opened', (
    tester,
  ) async {
    final game = await startGame(tester, FakePokeApiService());
    for (var room = 1; room < chestRoom; room++) {
      await clearRoomAndChooseSkill(tester, game);
      await pumpUntil(tester, () => game.roomNumber.value == room + 1);
    }
    final chestsBefore = game.tracker.chestsOpened;
    final player = game.player!..position = Vector2(200, 200);

    await clearRoomAndChooseSkill(tester, game);
    await pumpUntil(tester, () => chestsOf(game).isNotEmpty);
    for (var frame = 0; frame < waitingFrames; frame++) {
      await tester.pump(frameDuration);
    }

    expect(game.hasPendingChest, isTrue);
    expect(game.roomNumber.value, chestRoom);
    expect(livingEnemies(game), isEmpty);

    final coinsBefore = game.coins.value;
    player.position = chestsOf(game).first.position.clone();
    await pumpUntil(tester, () => !game.hasPendingChest);

    expect(game.tracker.chestsOpened, chestsBefore + 1);
    expect(game.coins.value, greaterThan(coinsBefore));
    expect(game.toastMessage.value, startsWith('Coffre'));

    await pumpUntil(tester, () => game.roomNumber.value == chestRoom + 1);
    await pumpUntil(tester, () => chestsOf(game).isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an ignored chest opens by itself after eight seconds', (
    tester,
  ) async {
    final game = await startGame(tester, FakePokeApiService());
    for (var room = 1; room < chestRoom; room++) {
      await clearRoomAndChooseSkill(tester, game);
      await pumpUntil(tester, () => game.roomNumber.value == room + 1);
    }
    game.player!.position = Vector2(200, 200);

    await clearRoomAndChooseSkill(tester, game);
    await pumpUntil(tester, () => chestsOf(game).isNotEmpty);
    await pumpUntil(tester, () => !game.hasPendingChest);

    expect(game.tracker.chestsOpened, greaterThanOrEqualTo(1));
    await pumpUntil(tester, () => game.roomNumber.value == chestRoom + 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
