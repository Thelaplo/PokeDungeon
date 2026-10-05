import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';

import '../../game/dungeon_game.dart';
import '../../models/run_config.dart';
import '../../models/run_result.dart';
import '../../services/poke_api_service.dart';
import '../hub/hub_style.dart';
import 'bag/bag_overlay.dart';
import 'game_loading_view.dart';
import 'hud/game_hud_overlay.dart';
import 'pause/pause_overlay.dart';
import 'skill_choice/skill_choice_overlay.dart';
import 'summary/run_summary_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({required this.config, required this.api, super.key});

  final RunConfig config;
  final PokeApiService api;

  static Route<RunResult> route({
    required RunConfig config,
    required PokeApiService api,
  }) => MaterialPageRoute<RunResult>(
    builder: (context) => GameScreen(config: config, api: api),
  );

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final DungeonGame _game = DungeonGame(
    config: widget.config,
    api: widget.api,
  );
  final FocusNode _gameFocusNode = FocusNode(debugLabel: 'game');
  bool _hasPopped = false;

  @override
  void dispose() {
    _gameFocusNode.dispose();
    super.dispose();
  }

  void _focusGame() => _gameFocusNode.requestFocus();

  void _continueWithResult() {
    final result = _game.result;
    if (result == null || _hasPopped) {
      return;
    }
    _hasPopped = true;
    Navigator.of(context).pop(result);
  }

  void _handleBackRequest() {
    if (_game.isRunOver) {
      _continueWithResult();
      return;
    }
    if (_game.isPauseMenuOpen) {
      _game.resumeFromPause();
      _focusGame();
      return;
    }
    _game.openPauseMenu();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<RunResult>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _handleBackRequest();
      },
      child: Scaffold(
        backgroundColor: HubStyle.backgroundBottom,
        body: GameWidget<DungeonGame>(
          game: _game,
          focusNode: _gameFocusNode,
          initialActiveOverlays: const [DungeonGame.hudOverlay],
          loadingBuilder: (context) => const GameLoadingView(),
          overlayBuilderMap: {
            DungeonGame.hudOverlay: (context, game) =>
                GameHudOverlay(game: game),
            DungeonGame.inventoryOverlay: (context, game) =>
                BagOverlay(game: game, onClosed: _focusGame),
            DungeonGame.skillChoiceOverlay: (context, game) =>
                SkillChoiceOverlay(game: game, onChosen: _focusGame),
            DungeonGame.pauseOverlay: (context, game) =>
                PauseOverlay(game: game, onResumed: _focusGame),
            DungeonGame.runSummaryOverlay: (context, game) =>
                _buildRunSummary(game),
          },
        ),
      ),
    );
  }

  Widget _buildRunSummary(DungeonGame game) {
    final result = game.result;
    if (result == null) {
      return const SizedBox.shrink();
    }
    return RunSummaryOverlay(
      chapter: game.chapter,
      hero: game.hero,
      result: result,
      chestsOpened: game.tracker.chestsOpened,
      onContinue: _continueWithResult,
    );
  }
}
