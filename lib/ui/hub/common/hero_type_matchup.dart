import 'package:flutter/material.dart';

import '../../../models/hero_definition.dart';
import '../hub_style.dart';
import 'type_badge.dart';
import 'type_matchups.dart';

class HeroTypeMatchup extends StatelessWidget {
  const HeroTypeMatchup({required this.hero, super.key});

  final HeroDefinition hero;

  @override
  Widget build(BuildContext context) {
    final strongTargets = TypeMatchups.superEffectiveTargetsOf(hero.type);
    return Column(
      children: [
        Text(
          'Fort contre :',
          style: HubStyle.body(fontSize: 12, color: HubStyle.mutedText),
        ),
        const SizedBox(height: 4),
        if (strongTargets.isEmpty)
          Text(
            'aucun type',
            style: HubStyle.body(fontSize: 12, color: HubStyle.softText),
          )
        else
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final target in strongTargets)
                TypeBadge(type: target, isCompact: true),
            ],
          ),
      ],
    );
  }
}
