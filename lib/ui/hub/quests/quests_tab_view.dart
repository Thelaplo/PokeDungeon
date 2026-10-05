import 'package:flutter/material.dart';

import '../../../models/daily_quest.dart';
import '../../../profile/player_profile.dart';
import '../common/hub_empty_message.dart';
import '../common/hub_layout.dart';
import '../common/hub_snack_bar.dart';
import '../hub_style.dart';
import 'daily_bonus_card.dart';
import 'daily_quest_card.dart';
import 'quest_reset_countdown.dart';
import 'quest_reward_chips.dart';

class QuestsTabView extends StatelessWidget {
  const QuestsTabView({required this.profile, super.key});

  final PlayerProfile profile;

  void _claimQuest(BuildContext context, DailyQuest quest) {
    final isClaimed = profile.claimQuest(quest.id);
    showHubSnackBar(
      context,
      isClaimed
          ? 'Récompense obtenue : ${describeQuestReward(quest.reward)}'
          : 'Cette quête n\'est pas encore terminée.',
    );
  }

  void _claimDailyBonus(BuildContext context) {
    final isClaimed = profile.claimDailyBonus();
    showHubSnackBar(
      context,
      isClaimed
          ? 'Coffre bonus : ${describeQuestReward(profile.dailyBonusReward)}'
          : 'Réclame d\'abord toutes les quêtes du jour.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: profile,
      builder: (context, _) {
        final quests = profile.dailyQuests;
        return ListView(
          padding: const EdgeInsets.all(HubLayout.pagePadding),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Quêtes du jour',
                        style: HubStyle.title(fontSize: 22),
                      ),
                    ),
                  ),
                  const QuestResetCountdown(),
                ],
              ),
            ),
            DailyBonusCard(
              claimedQuestCount: profile.claimedQuestCount,
              questCount: quests.length,
              reward: profile.dailyBonusReward,
              canClaim: profile.canClaimDailyBonus,
              isClaimed: profile.isDailyBonusClaimed,
              onClaim: () => _claimDailyBonus(context),
            ),
            const SizedBox(height: HubLayout.cardSpacing + 4),
            if (quests.isEmpty)
              const HubEmptyMessage(
                message: 'Aucune quête aujourd\'hui. Reviens demain !',
                icon: Icons.assignment_rounded,
              ),
            for (final quest in quests)
              DailyQuestCard(
                quest: quest,
                onClaim: () => _claimQuest(context, quest),
              ),
          ],
        );
      },
    );
  }
}
