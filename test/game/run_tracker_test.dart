import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/items/item_catalog.dart';
import 'package:poke_dungeon/game/run_tracker.dart';
import 'package:poke_dungeon/models/enemy_rank.dart';

void main() {
  late RunTracker tracker;

  setUp(() => tracker = RunTracker(chapterNumber: 2));

  test('a fresh run reports nothing done', () {
    final result = tracker.buildResult(
      isVictory: false,
      unusedConsumables: const {},
    );

    expect(result.chapterNumber, 2);
    expect(result.roomsCleared, 0);
    expect(result.score, 0);
    expect(result.coinsEarned, 0);
    expect(result.enemiesDefeated, 0);
    expect(result.bossesDefeated, 0);
    expect(result.isDailyEventDefeated, isFalse);
    expect(result.consumablesUsed, 0);
    expect(result.foundEquipment, isEmpty);
    expect(result.unusedConsumables, isEmpty);
  });

  test('every defeated Pokémon counts and adds its score', () {
    tracker
      ..recordEnemyDefeated(EnemyRank.normal, scoreValue: 40)
      ..recordEnemyDefeated(EnemyRank.normal, scoreValue: 60);

    expect(tracker.enemiesDefeated, 2);
    expect(tracker.score, 100);
    expect(tracker.bossesDefeated, 0);
  });

  test('bosses count as bosses and as defeated Pokémon', () {
    tracker.recordEnemyDefeated(EnemyRank.boss, scoreValue: 500);

    expect(tracker.bossesDefeated, 1);
    expect(tracker.enemiesDefeated, 1);
    expect(tracker.isDailyEventDefeated, isFalse);
  });

  test('the daily legendary flags the daily event', () {
    tracker.recordEnemyDefeated(EnemyRank.dailyLegendary, scoreValue: 900);

    expect(tracker.isDailyEventDefeated, isTrue);
    expect(tracker.bossesDefeated, 0);
  });

  test('rooms cleared keeps the furthest room', () {
    tracker
      ..recordRoomCleared(3)
      ..recordRoomCleared(2);

    expect(tracker.roomsCleared, 3);
  });

  test('only positive coin amounts are earned', () {
    tracker
      ..recordCoinsCollected(12)
      ..recordCoinsCollected(0)
      ..recordCoinsCollected(-5)
      ..recordCoinsCollected(3);

    expect(tracker.coinsEarned, 15);
  });

  test('each used consumable is counted', () {
    tracker
      ..recordConsumableUsed()
      ..recordConsumableUsed();

    expect(tracker.consumablesUsed, 2);
  });

  test('found equipment is recorded once', () {
    expect(tracker.recordEquipmentFound(ItemCatalog.metalCoat), isTrue);
    expect(tracker.recordEquipmentFound(ItemCatalog.metalCoat), isFalse);
    expect(tracker.recordEquipmentFound(ItemCatalog.lifeOrb), isTrue);

    expect(tracker.foundEquipment, [
      ItemCatalog.metalCoat,
      ItemCatalog.lifeOrb,
    ]);
  });

  test('the result carries the whole run and drops empty stacks', () {
    tracker
      ..recordEnemyDefeated(EnemyRank.boss, scoreValue: 300)
      ..recordRoomCleared(10)
      ..recordCoinsCollected(42)
      ..recordConsumableUsed()
      ..recordEquipmentFound(ItemCatalog.leftovers);

    final result = tracker.buildResult(
      isVictory: true,
      unusedConsumables: {ItemCatalog.potion: 2, ItemCatalog.xAttack: 0},
    );

    expect(result.isVictory, isTrue);
    expect(result.roomsCleared, 10);
    expect(result.score, 300);
    expect(result.coinsEarned, 42);
    expect(result.bossesDefeated, 1);
    expect(result.consumablesUsed, 1);
    expect(result.foundEquipment, [ItemCatalog.leftovers]);
    expect(result.unusedConsumables, {ItemCatalog.potion: 2});
  });

  test('the result does not change when the run goes on', () {
    tracker.recordEquipmentFound(ItemCatalog.magnet);
    final result = tracker.buildResult(
      isVictory: false,
      unusedConsumables: const {},
    );

    tracker.recordEquipmentFound(ItemCatalog.quickClaw);

    expect(result.foundEquipment, [ItemCatalog.magnet]);
  });
}
