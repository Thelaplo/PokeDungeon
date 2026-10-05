import 'package:flutter/material.dart';

import '../../../models/item_definition.dart';
import '../../../models/run_config.dart';
import '../common/hub_empty_message.dart';
import 'owned_equipment_tile.dart';

class OwnedEquipmentGrid extends StatelessWidget {
  const OwnedEquipmentGrid({
    required this.ownedEquipment,
    required this.isEquipped,
    required this.onSelected,
    super.key,
  });

  static const _maxTileExtent = 104.0;
  static const _tileAspectRatio = 0.72;
  static const _spacing = 8.0;

  final List<OwnedEquipment> ownedEquipment;
  final bool Function(EquipmentItem item) isEquipped;
  final ValueChanged<EquipmentItem> onSelected;

  @override
  Widget build(BuildContext context) {
    if (ownedEquipment.isEmpty) {
      return const HubEmptyMessage(
        message: 'Aucun équipement pour le moment.\nVisite la boutique !',
        icon: Icons.inventory_2_rounded,
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _maxTileExtent,
        childAspectRatio: _tileAspectRatio,
        mainAxisSpacing: _spacing,
        crossAxisSpacing: _spacing,
      ),
      itemCount: ownedEquipment.length,
      itemBuilder: (context, index) {
        final owned = ownedEquipment[index];
        return OwnedEquipmentTile(
          owned: owned,
          isEquipped: isEquipped(owned.item),
          onTap: () => onSelected(owned.item),
        );
      },
    );
  }
}
