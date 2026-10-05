import 'package:flutter/material.dart';

import '../../../models/item_definition.dart';
import '../../../profile/chest_type.dart';
import '../common/currency_icon.dart';
import '../common/hub_button.dart';
import '../common/hub_currency.dart';
import '../common/hub_panel.dart';
import '../common/poke_ball_icon.dart';
import '../hub_style.dart';
import 'chest_presentation.dart';

class ChestCard extends StatelessWidget {
  const ChestCard({
    required this.type,
    required this.canOpen,
    required this.onOpen,
    super.key,
  });

  static const _ballSize = 72.0;

  final ChestType type;
  final bool canOpen;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final highlight = type.highlight;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        HubPanel(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          borderColor: type.borderColor,
          child: Column(
            children: [
              PokeBallIcon(size: _ballSize, style: type.ballStyle),
              const SizedBox(height: 10),
              Text(
                type.label,
                textAlign: TextAlign.center,
                style: HubStyle.title(fontSize: 19),
              ),
              const SizedBox(height: 2),
              Text(
                type.rarityRange,
                textAlign: TextAlign.center,
                style: HubStyle.body(fontSize: 12, color: HubStyle.mutedText),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: HubButton(
                  label: '${type.gemCost}',
                  isCompact: true,
                  semanticLabel:
                      'Ouvrir une ${type.label} pour ${type.gemCost} gemmes',
                  leading: const CurrencyIcon(
                    currency: HubCurrency.gems,
                    size: 18,
                  ),
                  onPressed: canOpen ? onOpen : null,
                ),
              ),
            ],
          ),
        ),
        if (highlight != null)
          Positioned(
            top: -10,
            right: -4,
            child: _HighlightRibbon(label: highlight),
          ),
      ],
    );
  }
}

class _HighlightRibbon extends StatelessWidget {
  const _HighlightRibbon({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.08,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          gradient: HubStyle.rarityGradient(ItemRarity.legendary),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: HubStyle.navy, width: 2),
        ),
        child: Text(label, style: HubStyle.title(fontSize: 12)),
      ),
    );
  }
}
