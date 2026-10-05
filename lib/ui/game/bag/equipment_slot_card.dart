import 'package:flutter/material.dart';

import '../../../models/item_definition.dart';
import '../../../models/run_config.dart';
import '../../hub/common/rarity_item_frame.dart';
import '../../hub/hub_style.dart';

class EquipmentSlotCard extends StatelessWidget {
  const EquipmentSlotCard({required this.slot, required this.owned, super.key});

  static const _width = 172.0;
  static const _frameSide = 64.0;

  final EquipmentSlot slot;
  final OwnedEquipment? owned;

  @override
  Widget build(BuildContext context) {
    final equipped = owned;
    final borderColor = equipped == null
        ? HubStyle.locked
        : HubStyle.rarityColor(equipped.item.rarity);
    return Container(
      width: _width,
      padding: const EdgeInsets.all(12),
      decoration: HubStyle.panelDecoration(
        borderColor: borderColor,
        radius: HubStyle.tileRadius,
      ),
      child: Column(
        children: [
          Text(
            slot.label,
            style: HubStyle.body(fontSize: 12, color: HubStyle.mutedText),
          ),
          const SizedBox(height: 8),
          if (equipped == null)
            const _EmptySlot()
          else
            RarityItemFrame(
              item: equipped.item,
              side: _frameSide,
              level: equipped.level,
              isEquipped: true,
            ),
          const SizedBox(height: 12),
          Text(
            equipped?.item.name ?? 'Vide',
            textAlign: TextAlign.center,
            style: HubStyle.title(
              fontSize: 15,
              color: equipped == null ? HubStyle.locked : borderColor,
            ),
          ),
          if (equipped != null) ...[
            const SizedBox(height: 4),
            Text(
              equipped.item.describeAtLevel(equipped.level).join('\n'),
              textAlign: TextAlign.center,
              style: HubStyle.body(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: EquipmentSlotCard._frameSide,
      height: EquipmentSlotCard._frameSide,
      decoration: BoxDecoration(
        color: HubStyle.navigationBar,
        borderRadius: BorderRadius.circular(HubStyle.tileRadius),
        border: Border.all(color: HubStyle.locked, width: 2),
      ),
      child: const Icon(Icons.add_rounded, color: HubStyle.locked, size: 30),
    );
  }
}
