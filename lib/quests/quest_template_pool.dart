import '../models/daily_quest.dart';
import 'quest_template.dart';

abstract final class QuestTemplatePool {
  static const all = [
    QuestTemplate(
      metric: QuestMetric.enemiesDefeated,
      describe: _describeEnemiesDefeated,
      tiers: [
        QuestTier(target: 25, reward: QuestReward(coins: 120, xp: 40)),
        QuestTier(target: 40, reward: QuestReward(coins: 200, xp: 60)),
        QuestTier(target: 60, reward: QuestReward(coins: 150, gems: 20)),
      ],
    ),
    QuestTemplate(
      metric: QuestMetric.bossesDefeated,
      describe: _describeBossesDefeated,
      tiers: [
        QuestTier(target: 1, reward: QuestReward(coins: 100, xp: 50)),
        QuestTier(target: 2, reward: QuestReward(gems: 20, xp: 60)),
        QuestTier(target: 3, reward: QuestReward(gems: 35, xp: 90)),
      ],
    ),
    QuestTemplate(
      metric: QuestMetric.roomsCleared,
      describe: _describeRoomsCleared,
      tiers: [
        QuestTier(target: 10, reward: QuestReward(coins: 100, xp: 40)),
        QuestTier(target: 15, reward: QuestReward(coins: 180, xp: 60)),
        QuestTier(target: 25, reward: QuestReward(gems: 25, xp: 80)),
      ],
    ),
    QuestTemplate(
      metric: QuestMetric.coinsEarned,
      describe: _describeCoinsEarned,
      tiers: [
        QuestTier(target: 200, reward: QuestReward(xp: 80)),
        QuestTier(target: 300, reward: QuestReward(gems: 15, xp: 50)),
        QuestTier(target: 500, reward: QuestReward(gems: 30, xp: 80)),
      ],
    ),
    QuestTemplate(
      metric: QuestMetric.consumablesUsed,
      describe: _describeConsumablesUsed,
      tiers: [
        QuestTier(target: 1, reward: QuestReward(coins: 60, xp: 30)),
        QuestTier(target: 2, reward: QuestReward(coins: 120, xp: 40)),
        QuestTier(target: 3, reward: QuestReward(coins: 100, gems: 10)),
      ],
    ),
    QuestTemplate(
      metric: QuestMetric.dailyEventDefeated,
      describe: _describeDailyEventDefeated,
      tiers: [QuestTier(target: 1, reward: QuestReward(coins: 150, gems: 30))],
    ),
    QuestTemplate(
      metric: QuestMetric.chaptersCompleted,
      describe: _describeChaptersCompleted,
      tiers: [QuestTier(target: 1, reward: QuestReward(gems: 40, xp: 120))],
    ),
    QuestTemplate(
      metric: QuestMetric.runsPlayed,
      describe: _describeRunsPlayed,
      tiers: [
        QuestTier(target: 2, reward: QuestReward(coins: 80, xp: 30)),
        QuestTier(target: 3, reward: QuestReward(coins: 150, xp: 50)),
        QuestTier(target: 5, reward: QuestReward(gems: 25, xp: 80)),
      ],
    ),
  ];

  static String _describeEnemiesDefeated(int target) =>
      'Vaincre $target Pokémon';

  static String _describeBossesDefeated(int target) => 'Battre $target boss';

  static String _describeRoomsCleared(int target) =>
      target == 1 ? 'Franchir 1 salle' : 'Franchir $target salles';

  static String _describeCoinsEarned(int target) => 'Gagner $target ₽';

  static String _describeConsumablesUsed(int target) =>
      target == 1 ? 'Utiliser 1 objet' : 'Utiliser $target objets';

  static String _describeDailyEventDefeated(int target) =>
      "Vaincre l'événement du jour";

  static String _describeChaptersCompleted(int target) =>
      target == 1 ? 'Terminer un chapitre' : 'Terminer $target chapitres';

  static String _describeRunsPlayed(int target) =>
      target == 1 ? 'Jouer 1 partie' : 'Jouer $target parties';
}
