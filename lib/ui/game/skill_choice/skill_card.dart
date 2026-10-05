import 'package:flutter/material.dart';

import '../../../models/skill_definition.dart';
import '../../hub/hub_style.dart';

class SkillCard extends StatelessWidget {
  const SkillCard({
    required this.skill,
    required this.shortcut,
    required this.currentLevel,
    required this.width,
    required this.onPressed,
    super.key,
  });

  static const height = 280.0;
  static const _radius = 22.0;
  static const _lipHeight = 6.0;
  static const _iconCircleSide = 64.0;
  static const _compactIconCircleSide = 46.0;
  static const _compactWidth = 130.0;
  static const _lightMix = 0.3;
  static const _darkMix = 0.35;
  static const _lipMix = 0.6;
  static const _descriptionBackground = Color(0x5508181E);

  final SkillDefinition skill;
  final int shortcut;
  final int currentLevel;
  final double width;
  final VoidCallback onPressed;

  Color get _lightColor => Color.lerp(skill.color, HubStyle.white, _lightMix)!;

  Color get _darkColor => Color.lerp(skill.color, HubStyle.navy, _darkMix)!;

  Color get _lipColor => Color.lerp(skill.color, HubStyle.navy, _lipMix)!;

  bool get _isCompact => width < _compactWidth;

  String get _levelLabel => skill.isHealOnly
      ? 'Instantané'
      : 'Niv. ${currentLevel + 1}/${skill.maxLevel}';

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(_radius);
    return Semantics(
      button: true,
      label: '${skill.name}, $_levelLabel, ${skill.describe().join(', ')}',
      excludeSemantics: true,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.only(bottom: _lipHeight),
        decoration: BoxDecoration(
          color: _lipColor,
          borderRadius: borderRadius,
          boxShadow: const [
            BoxShadow(color: HubStyle.navy, offset: Offset(0, 4)),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: borderRadius,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_lightColor, skill.color, _darkColor],
                ),
                border: Border.all(
                  color: HubStyle.white.withValues(alpha: 0.45),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _ShortcutBadge(shortcut: shortcut),
                        const Spacer(),
                        _LevelPill(label: _levelLabel),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _IconCircle(
                      icon: skill.icon,
                      color: _lipColor,
                      side: _isCompact
                          ? _compactIconCircleSide
                          : _iconCircleSide,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      skill.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: HubStyle.title(
                        fontSize: _isCompact ? 15 : 18,
                        outlineColor: _lipColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _descriptionBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            skill.describe().join('\n'),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.fade,
                            style: HubStyle.body(
                              fontSize: _isCompact ? 11 : 12,
                              color: HubStyle.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({
    required this.icon,
    required this.color,
    required this.side,
  });

  static const _iconRatio = 0.56;

  final IconData icon;
  final Color color;
  final double side;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: HubStyle.white,
        border: Border.all(color: color, width: 3),
        boxShadow: const [
          BoxShadow(color: HubStyle.navy, offset: Offset(0, 3)),
        ],
      ),
      child: Icon(icon, color: color, size: side * _iconRatio),
    );
  }
}

class _ShortcutBadge extends StatelessWidget {
  const _ShortcutBadge({required this.shortcut});

  final int shortcut;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: SkillCard._descriptionBackground,
        shape: BoxShape.circle,
        border: Border.all(color: HubStyle.white.withValues(alpha: 0.6)),
      ),
      child: Text('$shortcut', style: HubStyle.plainTitle(fontSize: 13)),
    );
  }
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: SkillCard._descriptionBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: HubStyle.body(fontSize: 11, color: HubStyle.white),
        ),
      ),
    );
  }
}
