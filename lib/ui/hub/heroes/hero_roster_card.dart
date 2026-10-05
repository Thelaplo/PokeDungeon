import 'package:flutter/material.dart';

import '../../../models/hero_definition.dart';
import '../common/currency_icon.dart';
import '../common/hero_portrait.dart';
import '../common/hub_button.dart';
import '../common/hub_currency.dart';
import '../hub_style.dart';

class HeroRosterCard extends StatelessWidget {
  const HeroRosterCard({
    required this.hero,
    required this.isUnlocked,
    required this.isSelected,
    required this.isPreviewed,
    required this.canBuy,
    required this.onTap,
    required this.onBuy,
    super.key,
  });

  static const width = 116.0;
  static const _portraitSide = 64.0;

  final HeroDefinition hero;
  final bool isUnlocked;
  final bool isSelected;
  final bool isPreviewed;
  final bool canBuy;
  final VoidCallback onTap;
  final VoidCallback onBuy;

  bool get _isBuyable => !isUnlocked && hero.unlock.kind == HeroUnlockKind.gems;

  Color get _borderColor {
    if (isSelected) {
      return HubStyle.accent;
    }
    return isPreviewed ? HubStyle.white : HubStyle.panelBorder;
  }

  String get _semanticLabel {
    final status = switch ((isSelected, isUnlocked)) {
      (true, _) => 'choisi',
      (false, true) => 'disponible',
      (false, false) => 'verrouillé, ${hero.unlock.describe()}',
    };
    return '${hero.name}, $status';
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);
    return SizedBox(
      width: width,
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(
            gradient: isPreviewed
                ? HubStyle.activeTabGradient
                : HubStyle.panelGradient,
            borderRadius: borderRadius,
            border: Border.all(color: _borderColor, width: isSelected ? 3 : 2),
            boxShadow: const [
              BoxShadow(color: HubStyle.navy, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Semantics(
                button: true,
                selected: isPreviewed,
                label: _semanticLabel,
                excludeSemantics: true,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: borderRadius,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            HeroPortrait(
                              hero: hero,
                              size: _portraitSide,
                              isSilhouette: !isUnlocked,
                            ),
                            if (!isUnlocked)
                              const Icon(
                                Icons.lock_rounded,
                                color: HubStyle.white,
                                size: 26,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    color: HubStyle.navy,
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            hero.name,
                            style: HubStyle.title(fontSize: 15),
                          ),
                        ),
                        _StatusLine(
                          hero: hero,
                          isUnlocked: isUnlocked,
                          isSelected: isSelected,
                          isBuyable: _isBuyable,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isBuyable)
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                  child: HubButton(
                    label: '${hero.unlock.value}',
                    isCompact: true,
                    semanticLabel:
                        'Débloquer ${hero.name} pour ${hero.unlock.value} gemmes',
                    leading: const CurrencyIcon(
                      currency: HubCurrency.gems,
                      size: 16,
                    ),
                    onPressed: canBuy ? onBuy : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.hero,
    required this.isUnlocked,
    required this.isSelected,
    required this.isBuyable,
  });

  final HeroDefinition hero;
  final bool isUnlocked;
  final bool isSelected;
  final bool isBuyable;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
        margin: const EdgeInsets.only(top: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        decoration: BoxDecoration(
          gradient: HubStyle.accentGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('Choisi', style: HubStyle.title(fontSize: 12)),
      );
    }
    if (isUnlocked || isBuyable) {
      return const SizedBox(height: 4);
    }
    return Text(
      hero.unlock.describe(),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: HubStyle.body(fontSize: 11, color: HubStyle.mutedText),
    );
  }
}
