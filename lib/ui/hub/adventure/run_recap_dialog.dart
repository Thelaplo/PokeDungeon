import 'package:flutter/material.dart';

import '../common/currency_icon.dart';
import '../common/hub_button.dart';
import '../common/hub_currency.dart';
import '../common/hub_dialog_frame.dart';
import '../common/rarity_item_frame.dart';
import '../hub_style.dart';
import 'run_recap.dart';

class RunRecapDialog extends StatelessWidget {
  const RunRecapDialog({required this.recap, super.key});

  final RunRecap recap;

  @override
  Widget build(BuildContext context) {
    final result = recap.result;
    return HubDialogFrame(
      borderColor: result.isVictory ? HubStyle.accent : HubStyle.panelBorder,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            liveRegion: true,
            child: Text(
              result.isVictory ? 'VICTOIRE !' : 'AVENTURE TERMINÉE',
              textAlign: TextAlign.center,
              style: HubStyle.title(
                fontSize: 30,
                color: result.isVictory ? HubStyle.accent : HubStyle.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Chapitre ${recap.chapter.number} · ${recap.chapter.name}',
            textAlign: TextAlign.center,
            style: HubStyle.body(color: HubStyle.mutedText),
          ),
          const SizedBox(height: 16),
          _RecapLine(
            label: 'Salles franchies',
            value: '${result.roomsCleared}/${recap.chapter.roomCount}',
          ),
          _RecapLine(
            label: 'Ennemis vaincus',
            value: '${result.enemiesDefeated}',
          ),
          _RecapLine(label: 'Boss vaincus', value: '${result.bossesDefeated}'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _RewardAmount(
                currency: HubCurrency.coins,
                amount: recap.coinsGained,
              ),
              if (recap.gemsGained > 0)
                _RewardAmount(
                  currency: HubCurrency.gems,
                  amount: recap.gemsGained,
                ),
            ],
          ),
          if (recap.hasLeveledUp) ...[
            const SizedBox(height: 14),
            _LevelUpBanner(
              previousLevel: recap.previousTrainerLevel,
              newLevel: recap.newTrainerLevel,
            ),
          ],
          if (recap.hasFoundEquipment) ...[
            const SizedBox(height: 14),
            Text('Objets trouvés', style: HubStyle.title(fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (final item in result.foundEquipment)
                  Tooltip(
                    message: item.name,
                    child: RarityItemFrame(item: item, side: 52),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: HubButton(
              label: 'CONTINUER',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecapLine extends StatelessWidget {
  const _RecapLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: HubStyle.body())),
          Text(value, style: HubStyle.title(fontSize: 16)),
        ],
      ),
    );
  }
}

class _RewardAmount extends StatelessWidget {
  const _RewardAmount({required this.currency, required this.amount});

  final HubCurrency currency;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$amount ${currency.name} gagnés',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CurrencyIcon(currency: currency, size: 28),
          const SizedBox(width: 6),
          Text(
            '+$amount',
            style: HubStyle.title(fontSize: 24, color: currency.color),
          ),
        ],
      ),
    );
  }
}

class _LevelUpBanner extends StatelessWidget {
  const _LevelUpBanner({required this.previousLevel, required this.newLevel});

  final int previousLevel;
  final int newLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: HubStyle.accentGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HubStyle.navy, width: 2),
      ),
      child: Column(
        children: [
          Text('NIVEAU SUPÉRIEUR !', style: HubStyle.title(fontSize: 20)),
          Text(
            'Dresseur Nv. $previousLevel → Nv. $newLevel',
            style: HubStyle.title(fontSize: 15),
          ),
        ],
      ),
    );
  }
}
