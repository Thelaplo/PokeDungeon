import 'package:flutter/material.dart';

import '../../../models/hero_definition.dart';
import '../common/hero_on_pedestal.dart';
import '../common/hero_type_matchup.dart';
import '../common/type_badge.dart';
import '../hub_style.dart';

class EquipmentHeroCenter extends StatelessWidget {
  const EquipmentHeroCenter({
    required this.hero,
    required this.onTap,
    super.key,
  });

  static const _pedestalSize = 124.0;

  final HeroDefinition hero;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Héros : ${hero.name}. Changer de héros',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HubStyle.panelRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: [
              HeroOnPedestal(hero: hero, size: _pedestalSize),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(hero.name, style: HubStyle.title(fontSize: 22)),
              ),
              const SizedBox(height: 4),
              TypeBadge(type: hero.type, isCompact: true),
              const SizedBox(height: 6),
              HeroTypeMatchup(hero: hero),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: HubStyle.activeTabGradient,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: HubStyle.panelBorder),
                ),
                child: Text(
                  hero.ability.label,
                  textAlign: TextAlign.center,
                  style: HubStyle.body(fontSize: 11, color: HubStyle.white),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.swap_horiz_rounded,
                    size: 16,
                    color: HubStyle.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Changer',
                    style: HubStyle.body(fontSize: 12, color: HubStyle.accent),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
