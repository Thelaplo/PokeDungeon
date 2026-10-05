import 'package:flutter/material.dart';

import '../common/segmented_progress_bar.dart';
import '../hub_style.dart';

class ChapterProgressRow extends StatelessWidget {
  const ChapterProgressRow({
    required this.bestRoom,
    required this.roomCount,
    required this.isCompleted,
    super.key,
  });

  final int bestRoom;
  final int roomCount;
  final bool isCompleted;

  String get _bestRoomLabel =>
      bestRoom <= 0 ? 'Meilleur : aucun' : 'Meilleur : $bestRoom/$roomCount';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: bestRoom <= 0
          ? 'Aucune salle franchie pour le moment'
          : 'Record : salle $bestRoom sur $roomCount',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 18,
                color: HubStyle.gold,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _bestRoomLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HubStyle.title(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SegmentedProgressBar(
            filledCount: bestRoom,
            totalCount: roomCount,
            color: isCompleted ? HubStyle.success : HubStyle.accent,
          ),
        ],
      ),
    );
  }
}
