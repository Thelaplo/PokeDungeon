import 'package:flutter/material.dart';

import '../common/hub_progress_bar.dart';
import '../hub_style.dart';

class TrainerLevelPanel extends StatelessWidget {
  const TrainerLevelPanel({
    required this.level,
    required this.experienceIntoLevel,
    required this.experienceForNextLevel,
    super.key,
  });

  final int level;
  final int experienceIntoLevel;
  final int experienceForNextLevel;

  double get _experienceRatio => experienceForNextLevel <= 0
      ? 1
      : experienceIntoLevel / experienceForNextLevel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Dresseur niveau $level, $experienceIntoLevel sur '
          '$experienceForNextLevel points d\'expérience',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Dresseur Nv. $level', style: HubStyle.title(fontSize: 18)),
          const SizedBox(height: 6),
          HubProgressBar(ratio: _experienceRatio),
          const SizedBox(height: 3),
          Text(
            '$experienceIntoLevel / $experienceForNextLevel XP',
            style: HubStyle.body(fontSize: 11, color: HubStyle.mutedText),
          ),
        ],
      ),
    );
  }
}
