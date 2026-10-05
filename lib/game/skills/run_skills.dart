import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../models/skill_definition.dart';
import '../../models/stat_modifiers.dart';
import 'skill_catalog.dart';

class RunSkills extends ChangeNotifier {
  static const draftSize = 3;

  final Map<SkillDefinition, int> _levels = {};

  int levelOf(SkillDefinition skill) => _levels[skill] ?? 0;

  bool isMaxed(SkillDefinition skill) => levelOf(skill) >= skill.maxLevel;

  Map<SkillDefinition, int> get acquired => Map.unmodifiable({
    for (final MapEntry(key: skill, value: level) in _levels.entries)
      if (!skill.isHealOnly) skill: level,
  });

  Iterable<StatModifiers> get modifiers sync* {
    for (final MapEntry(key: skill, value: level) in _levels.entries) {
      for (var stack = 0; stack < level; stack++) {
        yield skill.modifiers;
      }
    }
  }

  List<SkillDefinition> draft(
    Random random, {
    required bool isPlayerHurt,
    int size = draftSize,
  }) {
    final candidates =
        SkillCatalog.all
            .where((skill) => !isMaxed(skill))
            .where((skill) => isPlayerHurt || !skill.isHealOnly)
            .toList()
          ..shuffle(random);
    return candidates.take(size).toList(growable: false);
  }

  void acquire(SkillDefinition skill) {
    if (isMaxed(skill)) {
      return;
    }
    _levels[skill] = levelOf(skill) + 1;
    notifyListeners();
  }

  void reset() {
    _levels.clear();
    notifyListeners();
  }
}
