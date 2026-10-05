import 'package:flutter/material.dart';

import '../../../models/daily_quest.dart';
import '../common/currency_icon.dart';
import '../common/hub_currency.dart';
import '../hub_style.dart';

class QuestRewardChips extends StatelessWidget {
  const QuestRewardChips({required this.reward, super.key});

  final QuestReward reward;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Récompense : ${describeQuestReward(reward)}',
      excludeSemantics: true,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          if (reward.coins > 0)
            _RewardChip(
              icon: const CurrencyIcon(currency: HubCurrency.coins, size: 16),
              label: '+${reward.coins}',
              color: HubStyle.gold,
            ),
          if (reward.gems > 0)
            _RewardChip(
              icon: const CurrencyIcon(currency: HubCurrency.gems, size: 16),
              label: '+${reward.gems}',
              color: HubStyle.gem,
            ),
          if (reward.xp > 0)
            _RewardChip(
              icon: const Icon(
                Icons.star_rounded,
                size: 16,
                color: HubStyle.accent,
              ),
              label: '+${reward.xp} XP',
              color: HubStyle.accent,
            ),
        ],
      ),
    );
  }
}

String describeQuestReward(QuestReward reward) => [
  if (reward.coins > 0) '${reward.coins} ₽',
  if (reward.gems > 0) '${reward.gems} gemmes',
  if (reward.xp > 0) '${reward.xp} XP',
].join(', ');

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final Widget icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 2, 8, 2),
      decoration: BoxDecoration(
        color: HubStyle.deepNavy.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HubStyle.title(fontSize: 13, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
