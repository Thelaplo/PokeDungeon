import 'package:flutter/widgets.dart';

import 'stat_modifiers.dart';

class SkillDefinition {
  const SkillDefinition({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.maxLevel,
    this.modifiers = const StatModifiers(),
    this.healAmount = 0,
    this.healRatio = 0,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int maxLevel;
  final StatModifiers modifiers;
  final int healAmount;
  final double healRatio;

  bool get isHealOnly => modifiers.describe().isEmpty;

  List<String> describe() => [
    ...modifiers.describe(),
    if (healAmount > 0) 'Soigne $healAmount PV',
    if (healRatio > 0) 'Soigne ${(healRatio * 100).round()} % des PV',
  ];
}
