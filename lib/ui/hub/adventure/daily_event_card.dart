import 'package:flutter/material.dart';

import '../../../models/monster_data.dart';
import '../common/hub_panel.dart';
import '../common/monster_sprite.dart';
import '../hub_style.dart';

class DailyEventCard extends StatelessWidget {
  const DailyEventCard({
    required this.legendary,
    required this.eventRoom,
    super.key,
  });

  static const _spriteSide = 64.0;
  static const _haloSide = 72.0;
  static const _haloGradient = RadialGradient(
    colors: [Color(0xFFFFF1A8), Color(0x00FFC93C)],
  );

  final Future<MonsterData> legendary;
  final int eventRoom;

  @override
  Widget build(BuildContext context) {
    return HubPanel(
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
      borderColor: HubStyle.eventBorder,
      gradient: HubStyle.eventGradient,
      child: Row(
        children: [
          Container(
            width: _haloSide,
            height: _haloSide,
            decoration: const BoxDecoration(
              gradient: _haloGradient,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: MonsterSprite(monster: legendary, side: _spriteSide),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _EventChip(),
                const SizedBox(height: 4),
                FutureBuilder<MonsterData>(
                  future: legendary,
                  builder: (context, snapshot) => Text(
                    '${snapshot.data?.name ?? '???'} sauvage',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HubStyle.title(fontSize: 18),
                  ),
                ),
                Text(
                  'Apparaît en salle $eventRoom',
                  style: HubStyle.body(fontSize: 12, color: HubStyle.mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventChip extends StatelessWidget {
  const _EventChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: HubStyle.accentGradient,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HubStyle.navy, width: 1.5),
      ),
      child: Text('ÉVÉNEMENT DU JOUR', style: HubStyle.title(fontSize: 11)),
    );
  }
}
