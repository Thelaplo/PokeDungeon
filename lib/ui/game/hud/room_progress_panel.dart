import 'package:flutter/material.dart';

import '../../../game/dungeon_game.dart';
import '../../hub/common/segmented_progress_bar.dart';
import '../../hub/hub_style.dart';

class RoomProgressPanel extends StatelessWidget {
  const RoomProgressPanel({required this.game, super.key});

  static const _maxWidth = 300.0;

  final DungeonGame game;

  @override
  Widget build(BuildContext context) {
    final chapter = game.chapter;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
        decoration: HubStyle.panelDecoration(radius: 16),
        child: ListenableBuilder(
          listenable: Listenable.merge([game.roomNumber, game.roomTheme]),
          builder: (context, _) {
            final roomNumber = game.roomNumber.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chapitre ${chapter.number} · ${chapter.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HubStyle.body(fontSize: 10, color: HubStyle.mutedText),
                ),
                Text(
                  _roomLabel(roomNumber),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HubStyle.title(fontSize: 16),
                ),
                const SizedBox(height: 6),
                SegmentedProgressBar(
                  filledCount: roomNumber,
                  totalCount: chapter.roomCount,
                  color: HubStyle.accent,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _roomLabel(int roomNumber) {
    if (roomNumber == 0) {
      return 'Prépare-toi…';
    }
    final roomName = game.roomTheme.value.roomName;
    return 'Salle $roomNumber/${game.chapter.roomCount} · $roomName';
  }
}
