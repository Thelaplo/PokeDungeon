import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/models/daily_quest.dart';
import 'package:poke_dungeon/profile/profile_state.dart';
import 'package:poke_dungeon/quests/daily_quest_board.dart';
import 'package:poke_dungeon/quests/quest_template_pool.dart';
import 'package:poke_dungeon/quests/run_result_quest_metrics.dart';

import '../profile/profile_test_fixtures.dart';

final bigRun = buildRunResult(
  roomsCleared: 30,
  isVictory: true,
  coinsEarned: 1000,
  enemiesDefeated: 100,
  bossesDefeated: 5,
  isDailyEventDefeated: true,
  consumablesUsed: 5,
);

List<String> describeBoard(DailyQuestBoard board) => [
  for (final quest in board.quests)
    '${quest.id}|${quest.description}|${quest.target}',
];

void main() {
  group('generation', () {
    test('the template pool covers every quest metric', () {
      expect(
        QuestTemplatePool.all.map((template) => template.metric).toSet(),
        QuestMetric.values.toSet(),
      );
    });

    test('the same calendar day always yields the same quests', () {
      final morning = DailyQuestBoard.forDay(DateTime(2026, 10, 5, 7));
      final evening = DailyQuestBoard.forDay(DateTime(2026, 10, 5, 23, 59));

      expect(describeBoard(morning), describeBoard(evening));
    });

    test('each day offers three quests on distinct metrics', () {
      for (var dayOffset = 0; dayOffset < 30; dayOffset++) {
        final board = DailyQuestBoard.forDay(
          DateTime(2026, 10, 1).add(Duration(days: dayOffset)),
        );

        expect(board.quests, hasLength(DailyQuestBoard.questsPerDay));
        expect(
          board.quests.map((quest) => quest.metric).toSet(),
          hasLength(DailyQuestBoard.questsPerDay),
        );
      }
    });

    test('different days produce different quest boards', () {
      final boards = {
        for (var dayOffset = 0; dayOffset < 10; dayOffset++)
          describeBoard(
            DailyQuestBoard.forDay(
              DateTime(2026, 10, 1).add(Duration(days: dayOffset)),
            ),
          ).join(';'),
      };

      expect(boards.length, greaterThan(1));
    });

    test('new quests start without progress and unclaimed', () {
      final board = DailyQuestBoard.forDay(testToday);

      for (final quest in board.quests) {
        expect(quest.progress, 0);
        expect(quest.isClaimed, isFalse);
        expect(quest.description, isNotEmpty);
      }
    });
  });

  group('progress', () {
    test('a run advances each quest by its metric, capped at the target', () {
      final board = DailyQuestBoard.forDay(testToday).recordRun(bigRun);

      for (final quest in board.quests) {
        final amount = bigRun.amountFor(quest.metric);
        expect(quest.progress, amount > quest.target ? quest.target : amount);
      }
    });

    test('progress accumulates across runs', () {
      final board = DailyQuestBoard.forDay(testToday)
          .recordRun(buildRunResult())
          .recordRun(buildRunResult());

      for (final quest in board.quests) {
        final expected = quest.metric == QuestMetric.runsPlayed ? 2 : 0;
        expect(
          quest.progress,
          expected > quest.target ? quest.target : expected,
        );
      }
    });

    test('run results map to the quest metrics', () {
      final run = buildRunResult(isVictory: true, isDailyEventDefeated: true);

      expect(run.amountFor(QuestMetric.runsPlayed), 1);
      expect(run.amountFor(QuestMetric.chaptersCompleted), 1);
      expect(run.amountFor(QuestMetric.dailyEventDefeated), 1);
      expect(buildRunResult().amountFor(QuestMetric.chaptersCompleted), 0);
    });
  });

  group('claims through the profile', () {
    test('a completed quest gives its reward exactly once', () {
      final profile = buildProfile()..applyRunResult(bigRun);
      final quest = profile.dailyQuests.firstWhere(
        (dailyQuest) => dailyQuest.canClaim,
      );
      final coinsBefore = profile.coins;
      final gemsBefore = profile.gems;

      expect(profile.claimQuest(quest.id), isTrue);
      expect(profile.coins, coinsBefore + quest.reward.coins);
      expect(profile.gems, gemsBefore + quest.reward.gems);
      expect(
        profile.dailyQuests.firstWhere((claimed) => claimed.id == quest.id),
        isA<DailyQuest>().having(
          (claimed) => claimed.isClaimed,
          'claimed',
          true,
        ),
      );
      expect(profile.claimQuest(quest.id), isFalse);
      expect(profile.coins, coinsBefore + quest.reward.coins);
    });

    test('an incomplete quest cannot be claimed', () {
      final profile = buildProfile();

      expect(profile.claimQuest(profile.dailyQuests.first.id), isFalse);
    });

    test('an unknown quest id cannot be claimed', () {
      expect(buildProfile().claimQuest('quete-inconnue'), isFalse);
    });

    test('a quest reward grants coins, gems and trainer xp', () {
      final rewarded = ProfileState.fresh(testToday)
          .withReward(const QuestReward(coins: 80, gems: 20, xp: 130));

      expect(rewarded.coins, 80);
      expect(rewarded.gems, 20);
      expect(rewarded.trainer.level, 2);
      expect(rewarded.trainer.xpIntoLevel, 30);
    });
  });

  group('day rollover', () {
    test('a new day regenerates quests and resets progress', () {
      var now = testToday;
      final profile = buildProfile(clock: () => now)..applyRunResult(bigRun);
      final yesterdayIds = profile.dailyQuests.map((quest) => quest.id).toSet();

      now = testToday.add(const Duration(days: 1));

      expect(
        profile.dailyQuests.map((quest) => quest.id).toSet(),
        isNot(yesterdayIds),
      );
      expect(profile.dailyQuests.every((quest) => quest.progress == 0), isTrue);
    });

    test('a quest from a previous day can no longer be claimed', () {
      var now = testToday;
      final profile = buildProfile(clock: () => now)..applyRunResult(bigRun);
      final yesterdayQuest = profile.dailyQuests.firstWhere(
        (quest) => quest.canClaim,
      );

      now = testToday.add(const Duration(days: 1));

      expect(profile.claimQuest(yesterdayQuest.id), isFalse);
    });

    test('runs after midnight feed the new day board', () {
      var now = testToday;
      final profile = buildProfile(clock: () => now);
      now = testToday.add(const Duration(days: 1));

      profile.applyRunResult(buildRunResult());

      final runsQuests = profile.dailyQuests.where(
        (quest) => quest.metric == QuestMetric.runsPlayed,
      );
      for (final quest in runsQuests) {
        expect(quest.progress, 1);
      }
      expect(
        profile.dailyQuests.every((quest) => quest.id.startsWith('20261006')),
        isTrue,
      );
    });
  });
}
