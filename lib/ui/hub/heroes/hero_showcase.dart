import 'package:flutter/material.dart';

import '../../../models/hero_definition.dart';
import '../common/hero_on_pedestal.dart';
import '../common/hero_type_matchup.dart';
import '../common/type_badge.dart';
import '../common/hub_panel.dart';
import '../hub_style.dart';

class HeroShowcase extends StatelessWidget {
  const HeroShowcase({
    required this.hero,
    required this.isUnlocked,
    required this.isSelected,
    super.key,
  });

  static const _pedestalSize = 156.0;

  final HeroDefinition hero;
  final bool isUnlocked;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final statEffects = hero.modifiers.describe();
    return HubPanel(
      padding: const EdgeInsets.all(18),
      borderColor: isUnlocked ? hero.accentColor : HubStyle.panelBorder,
      child: Column(
        children: [
          HeroOnPedestal(
            hero: hero,
            size: _pedestalSize,
            isSilhouette: !isUnlocked,
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 4,
            children: [
              Semantics(
                header: true,
                child: Text(hero.name, style: HubStyle.title(fontSize: 30)),
              ),
              TypeBadge(type: hero.type),
            ],
          ),
          Text(hero.title, style: HubStyle.body(color: HubStyle.mutedText)),
          const SizedBox(height: 10),
          HeroTypeMatchup(hero: hero),
          const SizedBox(height: 14),
          _AbilityBlock(ability: hero.ability),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              if (statEffects.isEmpty)
                const _StatChip(label: 'Statistiques de base'),
              for (final effect in statEffects) _StatChip(label: effect),
            ],
          ),
          if (!isUnlocked) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_rounded,
                  size: 18,
                  color: HubStyle.accent,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Déblocage : ${hero.unlock.describe()}',
                    textAlign: TextAlign.center,
                    style: HubStyle.title(fontSize: 15, color: HubStyle.accent),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AbilityBlock extends StatelessWidget {
  const _AbilityBlock({required this.ability});

  final HeroAbility ability;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HubStyle.deepNavy.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt_rounded, color: HubStyle.accent, size: 20),
              const SizedBox(width: 4),
              Text(ability.label, style: HubStyle.title(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            ability.description,
            textAlign: TextAlign.center,
            style: HubStyle.body(),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: HubStyle.activeTabGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HubStyle.panelBorder),
      ),
      child: Text(
        label,
        style: HubStyle.body(fontSize: 12, color: HubStyle.white),
      ),
    );
  }
}
