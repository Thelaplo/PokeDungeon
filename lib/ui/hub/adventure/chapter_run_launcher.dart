import 'package:flutter/material.dart';

import '../../../models/chapter.dart';
import '../../../profile/player_profile.dart';
import '../../../services/poke_api_service.dart';
import '../../game/game_screen.dart';
import 'run_recap.dart';
import 'run_recap_dialog.dart';

class ChapterRunLauncher {
  const ChapterRunLauncher({required this.profile, required this.api});

  final PlayerProfile profile;
  final PokeApiService api;

  Future<void> launch(BuildContext context, Chapter chapter) async {
    final config = profile.prepareRun(chapter.number);
    final result = await Navigator.of(context)
        .push(GameScreen.route(config: config, api: api));
    if (result == null) {
      return;
    }
    final coinsBefore = profile.coins;
    final gemsBefore = profile.gems;
    final levelBefore = profile.trainerLevel;
    profile.applyRunResult(result);
    final recap = RunRecap(
      chapter: chapter,
      result: result,
      coinsGained: profile.coins - coinsBefore,
      gemsGained: profile.gems - gemsBefore,
      previousTrainerLevel: levelBefore,
      newTrainerLevel: profile.trainerLevel,
    );
    if (!context.mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => RunRecapDialog(recap: recap),
    );
  }
}
