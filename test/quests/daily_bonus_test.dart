import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/models/daily_quest.dart';
import 'package:poke_dungeon/profile/player_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profile/profile_test_fixtures.dart';

const runsToCompleteEveryQuest = 5;

final bigRun = buildRunResult(
  roomsCleared: 30,
  isVictory: true,
  coinsEarned: 1000,
  enemiesDefeated: 100,
  bossesDefeated: 5,
  isDailyEventDefeated: true,
  consumablesUsed: 5,
);

void completeEveryQuest(PlayerProfile profile) {
  for (var run = 0; run < runsToCompleteEveryQuest; run++) {
    profile.applyRunResult(bigRun);
  }
}

void claimQuests(PlayerProfile profile, int count) {
  for (final quest in profile.dailyQuests.take(count)) {
    expect(profile.claimQuest(quest.id), isTrue);
  }
}

void main() {
  test('the daily bonus reward is 150 coins, 30 gems and 50 xp', () {
    final reward = buildProfile().dailyBonusReward;

    expect(reward.coins, 150);
    expect(reward.gems, 30);
    expect(reward.xp, 50);
  });

  test('the bonus stays locked until all three quests are claimed', () {
    final profile = buildProfile();
    completeEveryQuest(profile);

    for (final quest in profile.dailyQuests) {
      expect(profile.canClaimDailyBonus, isFalse);
      expect(profile.claimDailyBonus(), isFalse);
      expect(profile.claimQuest(quest.id), isTrue);
    }

    expect(profile.claimedQuestCount, 3);
    expect(profile.canClaimDailyBonus, isTrue);
  });

  test('claiming the bonus grants its reward exactly once', () {
    final profile = buildProfile();
    completeEveryQuest(profile);
    claimQuests(profile, 3);
    final coinsBefore = profile.coins;
    final gemsBefore = profile.gems;

    expect(profile.claimDailyBonus(), isTrue);
    expect(profile.coins, coinsBefore + profile.dailyBonusReward.coins);
    expect(profile.gems, gemsBefore + profile.dailyBonusReward.gems);
    expect(profile.isDailyBonusClaimed, isTrue);
    expect(profile.canClaimDailyBonus, isFalse);

    expect(profile.claimDailyBonus(), isFalse);
    expect(profile.coins, coinsBefore + profile.dailyBonusReward.coins);
  });

  test('claiming the bonus notifies listeners', () {
    final profile = buildProfile();
    completeEveryQuest(profile);
    claimQuests(profile, 3);
    var notificationCount = 0;
    profile.addListener(() => notificationCount++);

    profile.claimDailyBonus();

    expect(notificationCount, 1);
  });

  test('the bonus resets on the next day', () {
    var now = testToday;
    final profile = buildProfile(clock: () => now);
    completeEveryQuest(profile);
    claimQuests(profile, 3);
    profile.claimDailyBonus();

    now = testToday.add(const Duration(days: 1));

    expect(profile.isDailyBonusClaimed, isFalse);
    expect(profile.claimedQuestCount, 0);
    expect(profile.canClaimDailyBonus, isFalse);
  });

  group('persistence', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<PlayerProfile> loadAt(DateTime today) =>
        PlayerProfile.load(clock: () => today);

    test('a claimed bonus survives a reload on the same day', () async {
      final original = await loadAt(testToday);
      completeEveryQuest(original);
      claimQuests(original, 3);
      original.claimDailyBonus();
      await original.save();

      final reloaded = await loadAt(testToday.add(const Duration(hours: 2)));

      expect(reloaded.isDailyBonusClaimed, isTrue);
      expect(reloaded.claimedQuestCount, 3);
      expect(reloaded.claimDailyBonus(), isFalse);
    });

    test('an unclaimed bonus stays claimable after a reload', () async {
      final original = await loadAt(testToday);
      completeEveryQuest(original);
      claimQuests(original, 3);
      await original.save();

      final reloaded = await loadAt(testToday);

      expect(reloaded.canClaimDailyBonus, isTrue);
      expect(reloaded.claimDailyBonus(), isTrue);
    });

    test('a claimed bonus from yesterday is reset after a reload', () async {
      final original = await loadAt(testToday);
      completeEveryQuest(original);
      claimQuests(original, 3);
      original.claimDailyBonus();
      await original.save();

      final reloaded = await loadAt(testToday.add(const Duration(days: 1)));

      expect(reloaded.isDailyBonusClaimed, isFalse);
      expect(
        reloaded.dailyQuests.every((DailyQuest quest) => !quest.isClaimed),
        isTrue,
      );
    });
  });
}
