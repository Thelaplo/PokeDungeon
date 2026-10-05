import 'package:flutter/material.dart';

import '../../../models/daily_quest.dart';
import '../common/hub_button.dart';
import '../common/hub_panel.dart';
import '../common/poke_ball_icon.dart';
import '../common/segmented_progress_bar.dart';
import '../hub_style.dart';
import 'quest_reward_chips.dart';

class DailyBonusCard extends StatelessWidget {
  const DailyBonusCard({
    required this.claimedQuestCount,
    required this.questCount,
    required this.reward,
    required this.canClaim,
    required this.isClaimed,
    required this.onClaim,
    super.key,
  });

  static const _ballSize = 52.0;

  final int claimedQuestCount;
  final int questCount;
  final QuestReward reward;
  final bool canClaim;
  final bool isClaimed;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final shownCount = claimedQuestCount.clamp(0, questCount);
    return HubPanel(
      padding: const EdgeInsets.all(14),
      borderColor: canClaim ? HubStyle.accent : HubStyle.panelBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PokeBallIcon(size: _ballSize),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progression du jour',
                      style: HubStyle.title(fontSize: 19),
                    ),
                    Text(
                      'Réclame $questCount quêtes pour ouvrir le coffre bonus',
                      style: HubStyle.body(
                        fontSize: 12,
                        color: HubStyle.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$shownCount/$questCount',
                style: HubStyle.title(fontSize: 22, color: HubStyle.accent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            label: '$shownCount quêtes réclamées sur $questCount',
            excludeSemantics: true,
            child: SegmentedProgressBar(
              filledCount: shownCount,
              totalCount: questCount,
              color: HubStyle.accent,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: QuestRewardChips(reward: reward)),
              const SizedBox(width: 10),
              HubButton(
                label: isClaimed ? 'OUVERT' : 'COFFRE BONUS',
                isCompact: true,
                semanticLabel: isClaimed
                    ? 'Coffre bonus déjà ouvert'
                    : 'Ouvrir le coffre bonus',
                onPressed: canClaim ? onClaim : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
