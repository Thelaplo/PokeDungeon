import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/chapter.dart';
import '../../../models/monster_data.dart';
import '../common/monster_sprite.dart';
import '../hub_style.dart';
import 'chapter_ribbon.dart';
import 'chapter_scenery.dart';
import 'chapter_scenery_painter.dart';

class ChapterBossStage extends StatelessWidget {
  const ChapterBossStage({
    required this.chapter,
    required this.accentColor,
    required this.finalBoss,
    required this.isLocked,
    required this.isCompleted,
    super.key,
  });

  static const _bossHeightRatio = 0.55;
  static const _bossWidthRatio = 0.5;
  static const _groundOffsetRatio = 0.06;
  static const _lockIconSize = 64.0;

  final Chapter chapter;
  final Color accentColor;
  final Future<MonsterData> finalBoss;
  final bool isLocked;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bossSide = math.min(
          constraints.maxHeight * _bossHeightRatio,
          constraints.maxWidth * _bossWidthRatio,
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: ChapterSceneryPainter(
                scenery: ChapterScenery.forChapter(chapter),
                accentColor: accentColor,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: constraints.maxHeight * _groundOffsetRatio,
              child: Center(
                child: MonsterSprite(
                  monster: finalBoss,
                  side: bossSide,
                  isSilhouette: isLocked,
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Center(
                child: ChapterRibbon(
                  chapterNumber: chapter.number,
                  chapterName: chapter.name,
                  color: accentColor,
                ),
              ),
            ),
            if (isLocked)
              const ColoredBox(
                color: HubStyle.scrim,
                child: Center(
                  child: Icon(
                    Icons.lock_rounded,
                    size: _lockIconSize,
                    color: HubStyle.white,
                    semanticLabel: 'Chapitre verrouillé',
                    shadows: [
                      Shadow(offset: Offset(0, 3), color: HubStyle.navy),
                    ],
                  ),
                ),
              ),
            if (isCompleted)
              const Positioned(bottom: 10, right: 10, child: _CompletedBadge()),
          ],
        );
      },
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: HubStyle.successGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HubStyle.navy, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: HubStyle.white,
          ),
          const SizedBox(width: 4),
          Text('TERMINÉ', style: HubStyle.title(fontSize: 13)),
        ],
      ),
    );
  }
}
