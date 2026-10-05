import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../game/dungeon_game.dart';
import '../../../models/skill_definition.dart';
import '../../hub/hub_style.dart';
import '../common/game_overlay_frame.dart';
import 'skill_card.dart';

class SkillChoiceOverlay extends StatelessWidget {
  const SkillChoiceOverlay({
    required this.game,
    required this.onChosen,
    super.key,
  });

  static const _choiceKeys = [
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
  ];
  static const _cardSpacing = 12.0;
  static const _maxCardWidth = 180.0;
  static const _minCardWidth = 100.0;
  static const _maxContentWidth = 820.0;

  final DungeonGame game;
  final VoidCallback onChosen;

  void _choose(SkillDefinition skill) {
    game.chooseSkill(skill);
    onChosen();
  }

  @override
  Widget build(BuildContext context) {
    final offer = game.skillOffer;
    return CallbackShortcuts(
      bindings: {
        for (var index = 0; index < offer.length; index++)
          SingleActivator(_choiceKeys[index]): () => _choose(offer[index]),
      },
      child: Focus(
        autofocus: true,
        child: ColoredBox(
          color: GameOverlayFrame.scrimColor,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Salle ${game.roomNumber.value}/${game.chapter.roomCount} terminée !',
                        textAlign: TextAlign.center,
                        style: HubStyle.title(
                          fontSize: 28,
                          color: HubStyle.gold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choisis une compétence',
                        style: HubStyle.body(fontSize: 15),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) => _SkillCardGrid(
                          offer: offer,
                          levelOf: game.skills.levelOf,
                          availableWidth: constraints.maxWidth,
                          onChosen: _choose,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillCardGrid extends StatelessWidget {
  const _SkillCardGrid({
    required this.offer,
    required this.levelOf,
    required this.availableWidth,
    required this.onChosen,
  });

  static const _twoColumns = 2;

  final List<SkillDefinition> offer;
  final int Function(SkillDefinition skill) levelOf;
  final double availableWidth;
  final ValueChanged<SkillDefinition> onChosen;

  int get _columnCount {
    final widthPerCard =
        (availableWidth -
            SkillChoiceOverlay._cardSpacing * (offer.length - 1)) /
        offer.length;
    if (widthPerCard >= SkillChoiceOverlay._minCardWidth) {
      return offer.length;
    }
    return min(_twoColumns, offer.length);
  }

  @override
  Widget build(BuildContext context) {
    final columnCount = max(1, _columnCount);
    final cardWidth = min(
      SkillChoiceOverlay._maxCardWidth,
      (availableWidth - SkillChoiceOverlay._cardSpacing * (columnCount - 1)) /
          columnCount,
    );
    return Wrap(
      spacing: SkillChoiceOverlay._cardSpacing,
      runSpacing: SkillChoiceOverlay._cardSpacing,
      alignment: WrapAlignment.center,
      children: [
        for (var index = 0; index < offer.length; index++)
          SkillCard(
            skill: offer[index],
            shortcut: index + 1,
            currentLevel: levelOf(offer[index]),
            width: cardWidth,
            onPressed: () => onChosen(offer[index]),
          ),
      ],
    );
  }
}
