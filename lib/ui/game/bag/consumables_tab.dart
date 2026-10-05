import 'package:flutter/material.dart';

import '../../../game/dungeon_game.dart';
import '../../hub/common/hub_button.dart';
import '../../hub/common/hub_button_variant.dart';
import '../../hub/common/hub_empty_message.dart';
import '../../hub/common/hub_snack_bar.dart';
import '../common/game_item_tile.dart';

class ConsumablesTab extends StatelessWidget {
  const ConsumablesTab({required this.game, super.key});

  final DungeonGame game;

  @override
  Widget build(BuildContext context) {
    final consumables = game.inventory.consumables;
    if (consumables.isEmpty) {
      return const HubEmptyMessage(
        icon: Icons.inventory_2_rounded,
        message: 'Ton sac est vide.\nRamasse des Poké Balls pendant la course.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final MapEntry(key: item, value: count) in consumables.entries)
          GameItemTile(
            item: item,
            caption: 'x$count · ${item.rarity.label}',
            effects: item.describe(),
            trailing: HubButton(
              label: 'Utiliser',
              isCompact: true,
              variant: HubButtonVariant.secondary,
              onPressed: () {
                if (game.useConsumable(item)) {
                  showHubSnackBar(context, '${item.name} utilisé !');
                }
              },
            ),
          ),
      ],
    );
  }
}
