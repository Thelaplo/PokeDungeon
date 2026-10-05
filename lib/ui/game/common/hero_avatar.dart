import 'package:flutter/material.dart';

import '../../../models/hero_definition.dart';
import '../../hub/hub_style.dart';

class HeroAvatar extends StatelessWidget {
  const HeroAvatar({required this.hero, this.side = 44, super.key});

  static const _spriteRatio = 1.2;
  static const _iconRatio = 0.6;

  final HeroDefinition hero;
  final double side;

  @override
  Widget build(BuildContext context) {
    final spriteUrl = hero.spriteUrl;
    final fallbackIcon = Icon(
      Icons.person_rounded,
      color: HubStyle.white,
      size: side * _iconRatio,
    );
    return ExcludeSemantics(
      child: Container(
        width: side,
        height: side,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              hero.accentColor.withValues(alpha: 0.85),
              HubStyle.panelBottom,
            ],
          ),
          border: Border.all(color: hero.accentColor, width: 2.5),
          boxShadow: const [
            BoxShadow(color: HubStyle.navy, offset: Offset(0, 3)),
          ],
        ),
        alignment: Alignment.center,
        child: ClipOval(
          child: spriteUrl == null
              ? fallbackIcon
              : OverflowBox(
                  maxWidth: side * _spriteRatio,
                  maxHeight: side * _spriteRatio,
                  child: Image.network(
                    spriteUrl,
                    width: side * _spriteRatio,
                    height: side * _spriteRatio,
                    filterQuality: FilterQuality.none,
                    errorBuilder: (context, error, stackTrace) => fallbackIcon,
                  ),
                ),
        ),
      ),
    );
  }
}
