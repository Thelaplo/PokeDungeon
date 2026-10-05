import 'package:flutter/material.dart';

import '../../../models/daily_quest.dart';
import '../common/hub_button.dart';
import '../common/hub_button_variant.dart';
import '../common/hub_panel.dart';
import '../common/hub_progress_bar.dart';
import '../hub_style.dart';
import 'quest_metric_icon.dart';
import 'quest_reward_chips.dart';

class DailyQuestCard extends StatelessWidget {
  const DailyQuestCard({required this.quest, required this.onClaim, super.key});

  static const _iconSide = 44.0;

  final DailyQuest quest;
  final VoidCallback onClaim;

  Color get _borderColor {
    if (quest.canClaim) {
      return HubStyle.accent;
    }
    return quest.isClaimed ? HubStyle.success : HubStyle.panelBorder;
  }

  @override
  Widget build(BuildContext context) {
    final shownProgress = quest.progress.clamp(0, quest.target);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HubPanel(
        padding: const EdgeInsets.all(12),
        borderColor: _borderColor,
        child: Row(
          children: [
            Container(
              width: _iconSide,
              height: _iconSide,
              decoration: BoxDecoration(
                gradient: HubStyle.activeTabGradient,
                shape: BoxShape.circle,
                border: Border.all(color: HubStyle.navy, width: 2),
              ),
              child: Icon(quest.metric.icon, color: HubStyle.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quest.description, style: HubStyle.body(fontSize: 14)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: HubProgressBar(
                          ratio: quest.progressRatio,
                          gradient: quest.isCompleted
                              ? HubStyle.successGradient
                              : HubStyle.progressGradient,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$shownProgress/${quest.target}',
                        style: HubStyle.title(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  QuestRewardChips(reward: quest.reward),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _QuestAction(quest: quest, onClaim: onClaim),
          ],
        ),
      ),
    );
  }
}

class _QuestAction extends StatelessWidget {
  const _QuestAction({required this.quest, required this.onClaim});

  final DailyQuest quest;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    if (quest.isClaimed) {
      return Semantics(
        label: 'Récompense réclamée',
        excludeSemantics: true,
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: HubStyle.success,
              size: 30,
            ),
            Text(
              'Réclamée',
              style: HubStyle.body(fontSize: 11, color: HubStyle.success),
            ),
          ],
        ),
      );
    }
    if (!quest.canClaim) {
      return Text(
        'En cours',
        style: HubStyle.body(fontSize: 12, color: HubStyle.mutedText),
      );
    }
    return HubButton(
      label: 'RÉCLAMER',
      isCompact: true,
      variant: HubButtonVariant.secondary,
      semanticLabel: 'Réclamer la récompense : ${quest.description}',
      onPressed: onClaim,
    );
  }
}
