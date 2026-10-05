import 'package:flutter/material.dart';

import '../../../game/dungeon_game.dart';
import '../../hub/common/hub_icon_button.dart';
import '../../hub/hub_style.dart';
import 'acquired_skills_row.dart';
import 'bag_round_button.dart';
import 'boss_banner.dart';
import 'coins_pill.dart';
import 'game_message_bubble.dart';
import 'hero_status_panel.dart';
import 'room_progress_panel.dart';

class GameHudOverlay extends StatelessWidget {
  const GameHudOverlay({required this.game, super.key});

  static const _rightControlsWidth = 140.0;

  final DungeonGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            IgnorePointer(child: _HudInformation(game: game)),
            Align(
              alignment: Alignment.topRight,
              child: _TopRightControls(game: game),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 16),
                child: BagRoundButton(onPressed: game.openInventory),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudInformation extends StatelessWidget {
  const _HudInformation({required this.game});

  final DungeonGame game;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeroStatusPanel(game: game),
                  _ActiveBoostsRow(game: game),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const SizedBox(width: GameHudOverlay._rightControlsWidth),
          ],
        ),
        const SizedBox(height: 10),
        Center(child: RoomProgressPanel(game: game)),
        const SizedBox(height: 8),
        AcquiredSkillsRow(skills: game.skills),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: Listenable.merge([game.bossStatus, game.bossTypes]),
          builder: (context, _) {
            final bossStatus = game.bossStatus.value;
            if (bossStatus == null) {
              return const SizedBox.shrink();
            }
            return BossBanner(
              bossStatus: bossStatus,
              types: game.bossTypes.value,
            );
          },
        ),
        const Spacer(),
        GameMessageBubble(message: game.statusMessage),
        const SizedBox(height: 8),
        GameMessageBubble(
          message: game.toastMessage,
          borderColor: HubStyle.gold,
          textColor: HubStyle.gold,
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}

class _TopRightControls extends StatelessWidget {
  const _TopRightControls({required this.game});

  final DungeonGame game;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IgnorePointer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CoinsPill(coins: game.coins),
              const SizedBox(height: 4),
              ValueListenableBuilder<int>(
                valueListenable: game.score,
                builder: (context, score, _) => Text(
                  'Score $score',
                  style: HubStyle.body(fontSize: 11, color: HubStyle.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        HubIconButton(
          icon: Icons.pause_rounded,
          semanticLabel: 'Pause (P)',
          onPressed: game.openPauseMenu,
        ),
      ],
    );
  }
}

class _ActiveBoostsRow extends StatelessWidget {
  const _ActiveBoostsRow({required this.game});

  static const _boostColor = Color(0xFF22B783);

  final DungeonGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<BoostStatus>>(
      valueListenable: game.activeBoosts,
      builder: (context, boosts, _) => Wrap(
        spacing: 6,
        children: [
          for (final boost in boosts)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: _boostColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: HubStyle.navy, width: 1.5),
              ),
              child: Text(
                '${boost.name} ${boost.secondsLeft} s',
                style: HubStyle.body(fontSize: 11, color: HubStyle.white),
              ),
            ),
        ],
      ),
    );
  }
}
