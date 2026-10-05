import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../game/dungeon_game.dart';
import '../../hub/common/hub_button.dart';
import '../../hub/common/hub_button_variant.dart';
import '../../hub/common/segmented_progress_bar.dart';
import '../../hub/hub_style.dart';
import '../common/game_overlay_frame.dart';
import '../common/hero_ability_icons.dart';
import '../common/hero_avatar.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({required this.game, required this.onResumed, super.key});

  final DungeonGame game;
  final VoidCallback onResumed;

  void _resume() {
    game.resumeFromPause();
    onResumed();
  }

  @override
  Widget build(BuildContext context) {
    final chapter = game.chapter;
    final hero = game.hero;
    final roomNumber = game.roomNumber.value;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _resume,
        const SingleActivator(LogicalKeyboardKey.keyP): _resume,
      },
      child: Focus(
        autofocus: true,
        child: GameOverlayFrame(
          maxWidth: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pause',
                textAlign: TextAlign.center,
                style: HubStyle.title(fontSize: 34),
              ),
              const SizedBox(height: 4),
              Text(
                'Chapitre ${chapter.number} · ${chapter.name}',
                textAlign: TextAlign.center,
                style: HubStyle.body(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                'Salle $roomNumber/${chapter.roomCount}',
                textAlign: TextAlign.center,
                style: HubStyle.body(color: HubStyle.mutedText),
              ),
              const SizedBox(height: 6),
              SegmentedProgressBar(
                filledCount: roomNumber,
                totalCount: chapter.roomCount,
                color: HubStyle.accent,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  HeroAvatar(hero: hero, side: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hero.name, style: HubStyle.title(fontSize: 18)),
                        Row(
                          children: [
                            Icon(
                              HeroAbilityIcons.of(hero.ability),
                              size: 14,
                              color: hero.accentColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                hero.ability.description,
                                style: HubStyle.body(
                                  fontSize: 12,
                                  color: HubStyle.mutedText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              HubButton(
                label: 'Reprendre',
                variant: HubButtonVariant.secondary,
                onPressed: _resume,
              ),
              const SizedBox(height: 12),
              HubButton(
                label: 'Abandonner',
                isCompact: true,
                onPressed: game.abandonRun,
              ),
              const SizedBox(height: 8),
              Text(
                'Abandonner compte comme une défaite.',
                textAlign: TextAlign.center,
                style: HubStyle.body(fontSize: 12, color: HubStyle.mutedText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
