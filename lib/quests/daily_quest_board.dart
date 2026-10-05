import 'dart:math';

import '../models/daily_quest.dart';
import '../models/run_result.dart';
import 'daily_quest_copy.dart';
import 'quest_day.dart';
import 'quest_template.dart';
import 'quest_template_pool.dart';
import 'run_result_quest_metrics.dart';

class DailyQuestBoard {
  DailyQuestBoard._({
    required this.dayKey,
    required List<DailyQuest> quests,
    this.isBonusClaimed = false,
  }) : quests = List.unmodifiable(quests);

  factory DailyQuestBoard.forDay(DateTime day) {
    final dayKey = QuestDay.keyOf(day);
    return DailyQuestBoard._(dayKey: dayKey, quests: _generateQuests(dayKey));
  }

  factory DailyQuestBoard.fromJson(Map<String, Object?> json, DateTime today) {
    final board = DailyQuestBoard.forDay(today);
    if (json[_dayKeyField] != board.dayKey) return board;
    final savedQuests = json[_questsField] as Map<String, Object?>;
    final isBonusClaimed = json[_isBonusClaimedField] as bool? ?? false;
    return board._restoring(savedQuests)._withBonusClaimed(isBonusClaimed);
  }

  static const questsPerDay = 3;
  static const _dayKeyField = 'day';
  static const _questsField = 'quests';
  static const _progressField = 'progress';
  static const _isClaimedField = 'claimed';
  static const _isBonusClaimedField = 'bonusClaimed';
  static const bonusReward = QuestReward(coins: 150, gems: 30, xp: 50);

  final int dayKey;
  final List<DailyQuest> quests;
  final bool isBonusClaimed;

  int get claimedQuestCount => quests.where((quest) => quest.isClaimed).length;

  bool get areAllQuestsClaimed => claimedQuestCount == quests.length;

  bool get canClaimBonus => areAllQuestsClaimed && !isBonusClaimed;

  bool isFor(DateTime day) => QuestDay.keyOf(day) == dayKey;

  DailyQuest? questById(String questId) {
    for (final quest in quests) {
      if (quest.id == questId) return quest;
    }
    return null;
  }

  DailyQuestBoard recordRun(RunResult result) =>
      _mapQuests((quest) => quest.advancedBy(result.amountFor(quest.metric)));

  DailyQuestBoard markClaimed(String questId) => _mapQuests(
    (quest) => quest.id == questId ? quest.copyWith(isClaimed: true) : quest,
  );

  DailyQuestBoard markBonusClaimed() => _withBonusClaimed(true);

  Map<String, Object?> toJson() => {
    _dayKeyField: dayKey,
    _isBonusClaimedField: isBonusClaimed,
    _questsField: {
      for (final quest in quests)
        quest.id: {
          _progressField: quest.progress,
          _isClaimedField: quest.isClaimed,
        },
    },
  };

  DailyQuestBoard _mapQuests(DailyQuest Function(DailyQuest quest) transform) =>
      DailyQuestBoard._(
        dayKey: dayKey,
        quests: quests.map(transform).toList(),
        isBonusClaimed: isBonusClaimed,
      );

  DailyQuestBoard _withBonusClaimed(bool isClaimed) => DailyQuestBoard._(
    dayKey: dayKey,
    quests: quests,
    isBonusClaimed: isClaimed,
  );

  DailyQuestBoard _restoring(Map<String, Object?> savedQuests) =>
      _mapQuests((quest) {
        final savedQuest = savedQuests[quest.id] as Map<String, Object?>?;
        if (savedQuest == null) return quest;
        final savedProgress = savedQuest[_progressField] as int;
        return quest.copyWith(
          progress: savedProgress.clamp(0, quest.target),
          isClaimed: savedQuest[_isClaimedField] as bool,
        );
      });

  static List<DailyQuest> _generateQuests(int dayKey) {
    final random = Random(dayKey);
    final templates = [...QuestTemplatePool.all]..shuffle(random);
    return templates
        .take(questsPerDay)
        .map((template) => _questFrom(template, dayKey, random))
        .toList();
  }

  static DailyQuest _questFrom(
    QuestTemplate template,
    int dayKey,
    Random random,
  ) {
    final tier = template.tiers[random.nextInt(template.tiers.length)];
    return DailyQuest(
      id: '$dayKey-${template.metric.name}',
      description: template.describe(tier.target),
      metric: template.metric,
      target: tier.target,
      progress: 0,
      reward: tier.reward,
      isClaimed: false,
    );
  }
}
