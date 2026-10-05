import 'package:flutter/material.dart';

import '../../../models/chapter.dart';
import '../../../models/run_result.dart';
import '../../hub/common/currency_icon.dart';
import '../../hub/common/hub_currency.dart';
import '../../hub/hub_style.dart';

class RunStatisticsList extends StatelessWidget {
  const RunStatisticsList({
    required this.chapter,
    required this.result,
    required this.chestsOpened,
    super.key,
  });

  static const _rowColor = Color(0x5508181E);

  final Chapter chapter;
  final RunResult result;
  final int chestsOpened;

  @override
  Widget build(BuildContext context) {
    final rows = [
      _StatisticRow(
        leading: const Icon(Icons.meeting_room_rounded, color: HubStyle.accent),
        label: 'Salles franchies',
        value: '${result.roomsCleared}/${chapter.roomCount}',
      ),
      _StatisticRow(
        leading: const Icon(
          Icons.catching_pokemon_rounded,
          color: HubStyle.danger,
        ),
        label: 'Pokémon vaincus',
        value: '${result.enemiesDefeated}',
      ),
      _StatisticRow(
        leading: const Icon(
          Icons.local_fire_department_rounded,
          color: HubStyle.accent,
        ),
        label: 'Boss vaincus',
        value: '${result.bossesDefeated}',
      ),
      if (result.isDailyEventDefeated)
        const _StatisticRow(
          leading: Icon(
            Icons.auto_awesome_rounded,
            color: HubStyle.eventBorder,
          ),
          label: 'Événement du jour',
          value: 'Réussi',
          valueColor: HubStyle.eventBorder,
        ),
      _StatisticRow(
        leading: const Icon(Icons.redeem_rounded, color: HubStyle.gold),
        label: 'Coffres ouverts',
        value: '$chestsOpened',
      ),
      _StatisticRow(
        leading: const Icon(Icons.star_rounded, color: HubStyle.success),
        label: 'Score',
        value: '${result.score}',
      ),
      _StatisticRow(
        leading: const CurrencyIcon(currency: HubCurrency.coins, size: 22),
        label: '₽ gagnés',
        value: '${result.coinsEarned}',
        valueColor: HubStyle.gold,
      ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _rowColor,
        borderRadius: BorderRadius.circular(HubStyle.tileRadius),
      ),
      child: Column(children: rows),
    );
  }
}

class _StatisticRow extends StatelessWidget {
  const _StatisticRow({
    required this.leading,
    required this.label,
    required this.value,
    this.valueColor = HubStyle.white,
  });

  final Widget leading;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox.square(dimension: 24, child: Center(child: leading)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: HubStyle.body(fontSize: 14))),
          Text(value, style: HubStyle.title(fontSize: 18, color: valueColor)),
        ],
      ),
    );
  }
}
