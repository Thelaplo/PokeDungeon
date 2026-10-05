import 'package:flutter/material.dart';

import '../../../models/hero_definition.dart';

abstract final class HeroAbilityIcons {
  static IconData of(HeroAbility ability) => switch (ability) {
    HeroAbility.none => Icons.star_rounded,
    HeroAbility.chainLightning => Icons.bolt_rounded,
    HeroAbility.burn => Icons.local_fire_department_rounded,
    HeroAbility.shield => Icons.shield_rounded,
    HeroAbility.leech => Icons.eco_rounded,
    HeroAbility.adaptability => Icons.auto_awesome_rounded,
    HeroAbility.psychicPower => Icons.psychology_rounded,
  };
}
