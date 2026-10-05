import 'dart:math';

import 'package:flame/components.dart';

import '../../models/hero_definition.dart';
import '../skills/run_skills.dart';

abstract final class HeroAbilityRules {
  static const chainRange = 220.0;
  static const chainDamageRatio = 0.6;
  static const leechHealPerDefeat = 3;
  static const adaptabilityDraftSize = 4;
  static const unlimitedPiercing = 9999;

  static bool canChain(HeroAbility ability) =>
      ability == HeroAbility.chainLightning;

  static bool appliesBurn(HeroAbility ability) => ability == HeroAbility.burn;

  static bool hasShield(HeroAbility ability) => ability == HeroAbility.shield;

  static int chainDamage(int hitDamage) =>
      max(1, (hitDamage * chainDamageRatio).round());

  static int healOnDefeat(HeroAbility ability) =>
      ability == HeroAbility.leech ? leechHealPerDefeat : 0;

  static int skillDraftSize(HeroAbility ability) =>
      ability == HeroAbility.adaptability
      ? adaptabilityDraftSize
      : RunSkills.draftSize;

  static int projectilePiercing(HeroAbility ability, int basePiercing) =>
      ability == HeroAbility.psychicPower ? unlimitedPiercing : basePiercing;

  static T? nearestWithin<T>({
    required Vector2 origin,
    required Iterable<T> candidates,
    required Vector2 Function(T candidate) positionOf,
    double maxDistance = chainRange,
  }) {
    T? nearest;
    var nearestDistance = maxDistance * maxDistance;
    for (final candidate in candidates) {
      final distance = positionOf(candidate).distanceToSquared(origin);
      if (distance <= nearestDistance) {
        nearestDistance = distance;
        nearest = candidate;
      }
    }
    return nearest;
  }
}
