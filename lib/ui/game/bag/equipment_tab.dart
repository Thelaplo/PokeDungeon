import 'package:flutter/material.dart';

import '../../../game/dungeon_game.dart';
import '../../../models/item_definition.dart';
import '../../../models/player_stats.dart';
import '../../hub/common/hub_empty_message.dart';
import '../../hub/hub_style.dart';
import '../common/game_item_tile.dart';
import 'equipment_slot_card.dart';
import 'player_stats_panel.dart';

class EquipmentTab extends StatelessWidget {
  const EquipmentTab({required this.game, super.key});

  final DungeonGame game;

  @override
  Widget build(BuildContext context) {
    final inventory = game.inventory;
    final stats =
        game.player?.stats ?? PlayerStats.from(inventory.equipmentModifiers);
    final foundEquipment = game.tracker.foundEquipment;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Équipement fixé pour la course.',
          style: HubStyle.body(fontSize: 12, color: HubStyle.mutedText),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (final slot in EquipmentSlot.values)
              EquipmentSlotCard(slot: slot, owned: inventory.equippedIn(slot)),
          ],
        ),
        const SizedBox(height: 16),
        PlayerStatsPanel(stats: stats),
        const SizedBox(height: 16),
        Text('Trouvé pendant la course', style: HubStyle.title(fontSize: 18)),
        const SizedBox(height: 8),
        if (foundEquipment.isEmpty)
          const HubEmptyMessage(
            icon: Icons.workspace_premium_rounded,
            message: 'Bats un boss pour trouver de l\'équipement.',
          ),
        for (final item in foundEquipment)
          GameItemTile(
            item: item,
            caption: '${item.slot.label} · ${item.rarity.label}',
            effects: item.describe(),
            trailing: Text(
              'Nouveau',
              style: HubStyle.title(fontSize: 14, color: HubStyle.gold),
            ),
          ),
      ],
    );
  }
}
