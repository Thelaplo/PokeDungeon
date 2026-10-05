import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/chapters/chapter_catalog.dart';
import 'package:poke_dungeon/game/wave_plan.dart';
import 'package:poke_dungeon/models/chapter.dart';

const forestChapter = Chapter(
  number: 1,
  name: 'Forêt',
  subtitle: 'Plante · Insecte · Normal',
  pokemonTypes: ['grass', 'bug', 'normal'],
  difficulty: 1.0,
  finalBossId: 3,
);

const hardChapter = Chapter(
  number: 6,
  name: 'Tour',
  subtitle: 'Spectre · Poison',
  pokemonTypes: ['ghost', 'poison'],
  difficulty: 3.0,
  finalBossId: 94,
);

WavePlan roomOf(
  int roomNumber, {
  Chapter chapter = forestChapter,
  int dailyEventRoom = 0,
}) => WavePlan(
  chapter: chapter,
  roomNumber: roomNumber,
  dailyEventRoom: dailyEventRoom,
);

void main() {
  group('boss rooms', () {
    test('the mini boss room is the chapter mini boss room only', () {
      expect(roomOf(5).isMiniBossRoom, isTrue);
      expect(roomOf(4).isMiniBossRoom, isFalse);
      expect(roomOf(10).isMiniBossRoom, isFalse);
    });

    test('the last room is the final boss room', () {
      expect(roomOf(10).isFinalBossRoom, isTrue);
      expect(roomOf(9).isFinalBossRoom, isFalse);
      expect(roomOf(5).isFinalBossRoom, isFalse);
    });

    test('boss rooms only spawn a few minions', () {
      expect(roomOf(5).enemyCount, WavePlan.miniBossMinionCount);
      expect(roomOf(10).enemyCount, WavePlan.finalBossMinionCount);
    });

    test('a final boss is tougher than a mini boss', () {
      final finalRoom = roomOf(10);

      expect(
        finalRoom.finalBossHpMultiplier,
        greaterThan(finalRoom.bossHpMultiplier),
      );
      expect(
        finalRoom.bossHpMultiplier,
        greaterThan(finalRoom.enemyHpMultiplier),
      );
    });
  });

  group('normal rooms', () {
    test('enemy count grows with the room and is capped', () {
      expect(roomOf(1).enemyCount, 3);
      expect(roomOf(3).enemyCount, 5);
      expect(roomOf(9).enemyCount, 10);
    });

    test('enemies get tougher every room', () {
      expect(roomOf(1).enemyHpMultiplier, 1);
      expect(
        roomOf(6).enemyHpMultiplier,
        greaterThan(roomOf(2).enemyHpMultiplier),
      );
    });

    test('room themes cycle through the chapter types', () {
      expect(roomOf(1).theme.pokemonType, 'grass');
      expect(roomOf(2).theme.pokemonType, 'bug');
      expect(roomOf(3).theme.pokemonType, 'normal');
      expect(roomOf(4).theme.pokemonType, 'grass');
    });
  });

  group('daily event room', () {
    test('the legendary appears in the daily event room', () {
      expect(roomOf(4, dailyEventRoom: 4).isDailyEventRoom, isTrue);
      expect(roomOf(3, dailyEventRoom: 4).isDailyEventRoom, isFalse);
    });

    test('the legendary never shares a boss room', () {
      expect(roomOf(5, dailyEventRoom: 5).isDailyEventRoom, isFalse);
      expect(roomOf(10, dailyEventRoom: 10).isDailyEventRoom, isFalse);
    });

    test('the daily event room always exists and is never a boss room', () {
      final firstDay = DateTime(2026);
      for (var day = 0; day < 366; day++) {
        final eventRoom = WavePlan.dailyEventWaveFor(
          firstDay.add(Duration(days: day)),
        );
        for (final chapter in ChapterCatalog.all) {
          expect(eventRoom, inInclusiveRange(1, chapter.roomCount));
          expect(
            roomOf(
              eventRoom,
              chapter: chapter,
              dailyEventRoom: eventRoom,
            ).isDailyEventRoom,
            isTrue,
          );
        }
      }
    });

    test('the daily event room stays the same all day', () {
      expect(
        WavePlan.dailyEventWaveFor(DateTime(2026, 10, 5, 8)),
        WavePlan.dailyEventWaveFor(DateTime(2026, 10, 5, 23)),
      );
    });
  });

  group('difficulty scaling', () {
    test('enemy hp scales with the chapter difficulty', () {
      expect(
        roomOf(3, chapter: hardChapter).enemyHpMultiplier,
        closeTo(roomOf(3).enemyHpMultiplier * 3, 0.0001),
      );
    });

    test('contact damage is untouched in the first chapter', () {
      expect(roomOf(1).contactDamageMultiplier, 1);
    });

    test('contact damage grows with the chapter difficulty', () {
      expect(
        roomOf(1, chapter: hardChapter).contactDamageMultiplier,
        greaterThan(roomOf(1).contactDamageMultiplier),
      );
    });

    test('harder catalog chapters are never easier than earlier ones', () {
      final multipliers = [
        for (final chapter in ChapterCatalog.all)
          roomOf(1, chapter: chapter).enemyHpMultiplier,
      ];

      for (var index = 1; index < multipliers.length; index++) {
        expect(multipliers[index], greaterThan(multipliers[index - 1]));
      }
    });
  });

  group('random boss', () {
    test('a random boss comes from the pool and skips the excluded id', () {
      final random = Random(7);
      for (var draw = 0; draw < 200; draw++) {
        final bossId = WavePlan.randomBossId(random, excludedId: 3);

        expect(WavePlan.bossPoolIds, contains(bossId));
        expect(bossId, isNot(3));
      }
    });
  });

  group('daily legendary', () {
    test('the daily legendary stays the same all day', () {
      final morningBoss = WavePlan.dailyLegendaryId(DateTime(2026, 10, 5, 8));
      final eveningBoss = WavePlan.dailyLegendaryId(DateTime(2026, 10, 5, 23));

      expect(WavePlan.legendaryIds, contains(morningBoss));
      expect(eveningBoss, morningBoss);
    });

    test('the daily legendary changes across days', () {
      final bossesOverAMonth = {
        for (var day = 1; day <= 30; day++)
          WavePlan.dailyLegendaryId(DateTime(2026, 11, day)),
      };

      expect(bossesOverAMonth.length, greaterThan(1));
    });
  });
}
