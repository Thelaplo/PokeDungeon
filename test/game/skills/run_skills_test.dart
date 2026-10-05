import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/skills/run_skills.dart';
import 'package:poke_dungeon/game/skills/skill_catalog.dart';
import 'package:poke_dungeon/models/skill_definition.dart';

void maxOut(RunSkills skills, SkillDefinition skill) {
  for (var level = 0; level < skill.maxLevel; level++) {
    skills.acquire(skill);
  }
}

void maxOutEveryStatSkill(RunSkills skills) {
  for (final skill in SkillCatalog.all.where((skill) => !skill.isHealOnly)) {
    maxOut(skills, skill);
  }
}

void main() {
  late RunSkills skills;

  setUp(() => skills = RunSkills());

  test('a draft offers three different skills', () {
    final offer = skills.draft(Random(1), isPlayerHurt: true);

    expect(offer, hasLength(RunSkills.draftSize));
    expect(offer.toSet(), hasLength(RunSkills.draftSize));
  });

  test('healing skills are not offered at full health', () {
    for (var seed = 0; seed < 50; seed++) {
      final offer = skills.draft(Random(seed), isPlayerHurt: false);

      expect(offer.where((skill) => skill.isHealOnly), isEmpty);
    }
  });

  test('maxed skills are never offered again', () {
    maxOut(skills, SkillCatalog.rearShot);

    for (var seed = 0; seed < 50; seed++) {
      expect(
        skills.draft(Random(seed), isPlayerHurt: true),
        isNot(contains(SkillCatalog.rearShot)),
      );
    }
  });

  test('only healing is left once every stat skill is maxed', () {
    maxOutEveryStatSkill(skills);

    expect(skills.draft(Random(1), isPlayerHurt: true), [
      SkillCatalog.emergencyHeal,
    ]);
    expect(skills.draft(Random(1), isPlayerHurt: false), isEmpty);
  });

  test('acquiring past the max level does nothing', () {
    maxOut(skills, SkillCatalog.rearShot);
    skills.acquire(SkillCatalog.rearShot);

    expect(
      skills.levelOf(SkillCatalog.rearShot),
      SkillCatalog.rearShot.maxLevel,
    );
  });

  test('modifiers stack once per level', () {
    skills
      ..acquire(SkillCatalog.attackBoost)
      ..acquire(SkillCatalog.attackBoost)
      ..acquire(SkillCatalog.piercing);

    expect(skills.modifiers, hasLength(3));
  });

  test('healing skills are not listed as acquired', () {
    skills
      ..acquire(SkillCatalog.emergencyHeal)
      ..acquire(SkillCatalog.vampire);

    expect(skills.acquired, {SkillCatalog.vampire: 1});
  });
}
