import 'package:flutter/material.dart';

import '../../../models/hero_definition.dart';
import '../common/hero_portrait.dart';
import '../hub_style.dart';

class HeroAvatar extends StatelessWidget {
  const HeroAvatar({required this.hero, required this.level, super.key});

  static const _side = 60.0;
  static const _portraitSide = 50.0;
  static const _levelBubbleSpace = 8.0;

  final HeroDefinition hero;
  final int level;

  @override
  Widget build(BuildContext context) {
    final accent = hero.accentColor;
    return SizedBox(
      width: _side,
      height: _side + _levelBubbleSpace,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: _side,
            height: _side,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(accent, Colors.white, 0.35) ?? accent,
                  Color.lerp(accent, Colors.black, 0.3) ?? accent,
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: HubStyle.accent, width: 3),
              boxShadow: const [
                BoxShadow(color: HubStyle.navy, offset: Offset(0, 4)),
              ],
            ),
            alignment: Alignment.center,
            child: ClipOval(
              child: HeroPortrait(hero: hero, size: _portraitSide),
            ),
          ),
          Positioned(bottom: 0, child: _LevelBubble(level: level)),
        ],
      ),
    );
  }
}

class _LevelBubble extends StatelessWidget {
  const _LevelBubble({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: HubStyle.accentGradient,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HubStyle.navy, width: 2),
      ),
      child: Text('$level', style: HubStyle.title(fontSize: 14)),
    );
  }
}
