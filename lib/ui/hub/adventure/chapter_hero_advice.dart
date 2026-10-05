import 'package:flutter/material.dart';

import '../../../models/hero_definition.dart';
import '../common/hero_portrait.dart';
import '../hub_style.dart';

class ChapterHeroAdvice extends StatelessWidget {
  const ChapterHeroAdvice({
    required this.recommendedHeroes,
    required this.isHeroUnlocked,
    required this.isSelectedHeroVulnerable,
    super.key,
  });

  static const _portraitSide = 30.0;

  final List<HeroDefinition> recommendedHeroes;
  final bool Function(HeroDefinition hero) isHeroUnlocked;
  final bool isSelectedHeroVulnerable;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (recommendedHeroes.isNotEmpty)
          Semantics(
            label:
                'Héros conseillés : '
                '${recommendedHeroes.map((hero) => hero.name).join(', ')}',
            excludeSemantics: true,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                Text(
                  'Conseillé :',
                  style: HubStyle.body(fontSize: 12, color: HubStyle.mutedText),
                ),
                for (final hero in recommendedHeroes)
                  Tooltip(
                    message: hero.name,
                    child: _AdvisedHeroBubble(
                      hero: hero,
                      side: _portraitSide,
                      isUnlocked: isHeroUnlocked(hero),
                    ),
                  ),
              ],
            ),
          ),
        if (isSelectedHeroVulnerable) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: HubStyle.accent,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Ton héros est vulnérable ici',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HubStyle.body(fontSize: 12, color: HubStyle.accent),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _AdvisedHeroBubble extends StatelessWidget {
  const _AdvisedHeroBubble({
    required this.hero,
    required this.side,
    required this.isUnlocked,
  });

  final HeroDefinition hero;
  final double side;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: HubStyle.deepNavy.withValues(alpha: 0.7),
        shape: BoxShape.circle,
        border: Border.all(
          color: isUnlocked ? hero.type.color : HubStyle.locked,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: HeroPortrait(hero: hero, size: side, isSilhouette: !isUnlocked),
      ),
    );
  }
}
