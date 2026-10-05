import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/chapter.dart';
import '../../../models/hero_definition.dart';
import '../../../models/run_result.dart';
import '../../hub/common/hub_button.dart';
import '../../hub/common/segmented_progress_bar.dart';
import '../../hub/hub_style.dart';
import '../common/game_overlay_frame.dart';
import '../common/hero_avatar.dart';
import 'found_equipment_section.dart';
import 'run_statistics_list.dart';

class RunSummaryOverlay extends StatelessWidget {
  const RunSummaryOverlay({
    required this.chapter,
    required this.hero,
    required this.result,
    required this.chestsOpened,
    required this.onContinue,
    super.key,
  });

  final Chapter chapter;
  final HeroDefinition hero;
  final RunResult result;
  final int chestsOpened;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isVictory = result.isVictory;
    final accentColor = isVictory ? HubStyle.gold : HubStyle.accent;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, includeRepeats: false):
            onContinue,
      },
      child: Focus(
        autofocus: true,
        child: GameOverlayFrame(
          borderColor: accentColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: HeroAvatar(hero: hero, side: 64)),
              const SizedBox(height: 8),
              Text(
                isVictory ? 'Victoire !' : 'Défaite',
                textAlign: TextAlign.center,
                style: HubStyle.title(fontSize: 36, color: accentColor),
              ),
              Text(
                'Chapitre ${chapter.number} · ${chapter.name}',
                textAlign: TextAlign.center,
                style: HubStyle.body(fontSize: 14),
              ),
              const SizedBox(height: 12),
              SegmentedProgressBar(
                filledCount: result.roomsCleared,
                totalCount: chapter.roomCount,
                color: isVictory ? HubStyle.success : HubStyle.accent,
              ),
              const SizedBox(height: 16),
              RunStatisticsList(
                chapter: chapter,
                result: result,
                chestsOpened: chestsOpened,
              ),
              const SizedBox(height: 12),
              FoundEquipmentSection(foundEquipment: result.foundEquipment),
              const SizedBox(height: 20),
              HubButton(label: 'Continuer', onPressed: onContinue),
            ],
          ),
        ),
      ),
    );
  }
}
