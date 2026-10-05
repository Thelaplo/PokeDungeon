import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/chests/chest_schedule.dart';
import 'package:poke_dungeon/game/dungeon_game.dart';
import 'package:poke_dungeon/game/items/item_catalog.dart';

import 'support/fake_poke_api_service.dart';
import 'support/game_test_driver.dart';

void main() {
  testWidgets('a full chapter ends in a victory with tracked stats', (
    tester,
  ) async {
    final api = FakePokeApiService();
    final game = await startGame(tester, api);
    final chapter = game.chapter;

    for (var room = 1; room < chapter.roomCount; room++) {
      await clearCurrentRoom(tester, game);
      await pumpUntil(
        tester,
        () => game.overlays.isActive(DungeonGame.skillChoiceOverlay),
      );
      expect(game.roomNumber.value, room);
      expect(game.paused, isTrue);
      game.chooseSkill(game.skillOffer.first);
    }
    await clearCurrentRoom(tester, game);
    await pumpUntil(tester, () => game.isRunOver);

    final result = game.result!;
    expect(result.isVictory, isTrue);
    expect(result.chapterNumber, 1);
    expect(result.roomsCleared, chapter.roomCount);
    expect(result.bossesDefeated, 2);
    expect(result.isDailyEventDefeated, isTrue);
    expect(result.enemiesDefeated, greaterThan(chapter.roomCount));
    expect(result.coinsEarned, greaterThan(0));
    expect(result.coinsEarned, game.coins.value);
    expect(result.score, game.score.value);
    expect(result.foundEquipment, isNotEmpty);
    expect(
      game.tracker.chestsOpened,
      greaterThanOrEqualTo(ChestSchedule.guaranteedRooms.length),
    );
    expect(result.foundEquipment, isNot(contains(ItemCatalog.charcoal)));
    expect(game.overlays.isActive(DungeonGame.runSummaryOverlay), isTrue);
    expect(game.overlays.isActive(DungeonGame.hudOverlay), isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(api.isClosed, isFalse);
  });

  testWidgets('the pause menu keeps the skill choice paused', (tester) async {
    final game = await startGame(tester, FakePokeApiService());

    await clearCurrentRoom(tester, game);
    await pumpUntil(
      tester,
      () => game.overlays.isActive(DungeonGame.skillChoiceOverlay),
    );
    game
      ..openPauseMenu()
      ..resumeFromPause();

    expect(game.paused, isTrue);
    game.chooseSkill(game.skillOffer.first);
    expect(game.paused, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('abandoning from the pause menu ends in a defeat', (
    tester,
  ) async {
    final game = await startGame(tester, FakePokeApiService());

    await clearCurrentRoom(tester, game);
    game.openPauseMenu();
    expect(game.paused, isTrue);
    expect(game.isPauseMenuOpen, isTrue);

    game.abandonRun();

    final result = game.result!;
    expect(result.isVictory, isFalse);
    expect(result.roomsCleared, 1);
    expect(result.unusedConsumables[ItemCatalog.potion], 2);
    expect(game.isPauseMenuOpen, isFalse);
    expect(game.overlays.isActive(DungeonGame.runSummaryOverlay), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('used consumables are counted and removed from the bag', (
    tester,
  ) async {
    final game = await startGame(tester, FakePokeApiService());
    await pumpUntil(tester, () => game.player?.isMounted ?? false);

    expect(game.useConsumable(ItemCatalog.potion), isTrue);
    game.abandonRun();

    final result = game.result!;
    expect(result.consumablesUsed, 1);
    expect(result.unusedConsumables[ItemCatalog.potion], 1);
    expect(game.useConsumable(ItemCatalog.potion), isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
