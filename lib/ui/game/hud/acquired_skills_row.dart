import 'package:flutter/material.dart';

import '../../../game/skills/run_skills.dart';
import '../../../models/skill_definition.dart';
import '../../hub/hub_style.dart';

class AcquiredSkillsRow extends StatelessWidget {
  const AcquiredSkillsRow({required this.skills, super.key});

  final RunSkills skills;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: skills,
      builder: (context, _) {
        final acquired = skills.acquired;
        if (acquired.isEmpty) {
          return const SizedBox.shrink();
        }
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final MapEntry(key: skill, value: level) in acquired.entries)
              _SkillBadge(skill: skill, level: level),
          ],
        );
      },
    );
  }
}

class _SkillBadge extends StatelessWidget {
  const _SkillBadge({required this.skill, required this.level});

  static const _side = 30.0;

  final SkillDefinition skill;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${skill.name} niveau $level',
      child: SizedBox(
        width: _side + 6,
        height: _side + 6,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: _side,
              height: _side,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: skill.color,
                border: Border.all(color: HubStyle.navy, width: 2),
                boxShadow: const [
                  BoxShadow(color: HubStyle.navy, offset: Offset(0, 2)),
                ],
              ),
              child: Icon(skill.icon, size: 17, color: HubStyle.white),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: HubStyle.navy,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: HubStyle.panelBorder),
                ),
                child: Text('$level', style: HubStyle.plainTitle(fontSize: 10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
