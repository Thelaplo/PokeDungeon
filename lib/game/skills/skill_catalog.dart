import 'package:flutter/material.dart';

import '../../models/skill_definition.dart';
import '../../models/stat_modifiers.dart';

abstract final class SkillCatalog {
  static const multishot = SkillDefinition(
    id: 'multishot',
    name: 'Tir multiple',
    icon: Icons.keyboard_double_arrow_up,
    color: Color(0xFFFF7A2A),
    maxLevel: 3,
    modifiers: StatModifiers(extraProjectiles: 1, damagePercent: -0.1),
  );
  static const diagonalShots = SkillDefinition(
    id: 'diagonal-shots',
    name: 'Flèches diagonales',
    icon: Icons.call_split,
    color: Color(0xFFFF7A2A),
    maxLevel: 2,
    modifiers: StatModifiers(diagonalShotPairs: 1),
  );
  static const rearShot = SkillDefinition(
    id: 'rear-shot',
    name: 'Tir arrière',
    icon: Icons.u_turn_left,
    color: Color(0xFFFF7A2A),
    maxLevel: 1,
    modifiers: StatModifiers(rearShots: 1),
  );
  static const piercing = SkillDefinition(
    id: 'piercing',
    name: 'Perforation',
    icon: Icons.arrow_forward,
    color: Color(0xFFFF7A2A),
    maxLevel: 2,
    modifiers: StatModifiers(piercing: 1),
  );
  static const attackBoost = SkillDefinition(
    id: 'attack-boost',
    name: 'Attaque renforcée',
    icon: Icons.flash_on,
    color: Color(0xFFE83838),
    maxLevel: 5,
    modifiers: StatModifiers(damagePercent: 0.2),
  );
  static const rapidFire = SkillDefinition(
    id: 'rapid-fire',
    name: 'Tir rapide',
    icon: Icons.speed,
    color: Color(0xFFE83838),
    maxLevel: 5,
    modifiers: StatModifiers(fireRatePercent: 0.2),
  );
  static const lightStep = SkillDefinition(
    id: 'light-step',
    name: 'Pas léger',
    icon: Icons.directions_run,
    color: Color(0xFF4AB8FF),
    maxLevel: 3,
    modifiers: StatModifiers(speedPercent: 0.15),
  );
  static const vitality = SkillDefinition(
    id: 'vitality',
    name: 'Vitalité',
    icon: Icons.favorite,
    color: Color(0xFF40E060),
    maxLevel: 5,
    modifiers: StatModifiers(maxHpBonus: 25),
    healAmount: 25,
  );
  static const regeneration = SkillDefinition(
    id: 'regeneration',
    name: 'Régénération',
    icon: Icons.spa,
    color: Color(0xFF40E060),
    maxLevel: 3,
    modifiers: StatModifiers(regenPerSecond: 0.8),
  );
  static const vampire = SkillDefinition(
    id: 'vampire',
    name: 'Vampirisme',
    icon: Icons.bloodtype,
    color: Color(0xFFC060F0),
    maxLevel: 3,
    modifiers: StatModifiers(healOnHit: 1),
  );
  static const armor = SkillDefinition(
    id: 'armor',
    name: 'Cuirasse',
    icon: Icons.shield,
    color: Color(0xFF4AB8FF),
    maxLevel: 3,
    modifiers: StatModifiers(damageReduction: 0.08),
  );
  static const emergencyHeal = SkillDefinition(
    id: 'emergency-heal',
    name: 'Soin d\'urgence',
    icon: Icons.healing,
    color: Color(0xFF40E060),
    maxLevel: 999,
    healRatio: 0.5,
  );

  static const all = [
    multishot,
    diagonalShots,
    rearShot,
    piercing,
    attackBoost,
    rapidFire,
    lightStep,
    vitality,
    regeneration,
    vampire,
    armor,
    emergencyHeal,
  ];
}
