import 'package:flutter/material.dart';

import '../../../models/chapter.dart';
import '../../../models/hero_definition.dart';
import '../../../models/monster_data.dart';
import '../common/type_badge.dart';
import '../common/type_matchups.dart';
import '../hub_style.dart';
import 'chapter_boss_stage.dart';
import 'chapter_hero_advice.dart';
import 'chapter_progress_row.dart';

class ChapterCard extends StatelessWidget {
  const ChapterCard({
    required this.chapter,
    required this.finalBoss,
    required this.bestRoom,
    required this.isCompleted,
    required this.isLocked,
    required this.recommendedHeroes,
    required this.isHeroUnlocked,
    required this.isSelectedHeroVulnerable,
    super.key,
  });

  static const _radius = 22.0;
  static const _innerRadius = 19.0;

  final Chapter chapter;
  final Future<MonsterData> finalBoss;
  final int bestRoom;
  final bool isCompleted;
  final bool isLocked;
  final List<HeroDefinition> recommendedHeroes;
  final bool Function(HeroDefinition hero) isHeroUnlocked;
  final bool isSelectedHeroVulnerable;

  Color get _accentColor =>
      isLocked ? HubStyle.locked : chapter.themes.first.accentColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Chapitre ${chapter.number}, ${chapter.name}'
          '${isLocked ? ', verrouillé' : ''}'
          '${isCompleted ? ', terminé' : ''}',
      child: Container(
        margin: const EdgeInsets.fromLTRB(6, 4, 6, 10),
        decoration: BoxDecoration(
          gradient: HubStyle.panelGradient,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(
            color: isLocked ? HubStyle.panelBorder : _accentColor,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: HubStyle.deepNavy,
              offset: HubStyle.panelShadowOffset,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_innerRadius),
          child: Column(
            children: [
              Expanded(
                child: ChapterBossStage(
                  chapter: chapter,
                  accentColor: _accentColor,
                  finalBoss: finalBoss,
                  isLocked: isLocked,
                  isCompleted: isCompleted,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final type in TypeMatchups.chapterTypes(chapter))
                          TypeBadge(type: type, isCompact: true),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ChapterHeroAdvice(
                      recommendedHeroes: recommendedHeroes,
                      isHeroUnlocked: isHeroUnlocked,
                      isSelectedHeroVulnerable: isSelectedHeroVulnerable,
                    ),
                    const SizedBox(height: 8),
                    if (isLocked)
                      _LockedHint(previousChapterNumber: chapter.number - 1)
                    else
                      ChapterProgressRow(
                        bestRoom: bestRoom,
                        roomCount: chapter.roomCount,
                        isCompleted: isCompleted,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedHint extends StatelessWidget {
  const _LockedHint({required this.previousChapterNumber});

  final int previousChapterNumber;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.lock_rounded, size: 18, color: HubStyle.mutedText),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Termine le chapitre $previousChapterNumber pour débloquer',
            style: HubStyle.body(color: HubStyle.softText),
          ),
        ),
      ],
    );
  }
}
