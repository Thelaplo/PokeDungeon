import 'package:flutter/material.dart';

import '../../../models/item_definition.dart';
import '../../../models/run_config.dart';
import '../common/rarity_item_frame.dart';
import '../hub_style.dart';
import 'equipment_slot_icon.dart';

class EquippedSlotCard extends StatelessWidget {
  const EquippedSlotCard({
    required this.slot,
    required this.equipped,
    required this.onTap,
    super.key,
  });

  static const _frameSide = 64.0;

  final EquipmentSlot slot;
  final OwnedEquipment? equipped;
  final VoidCallback onTap;

  String get _semanticLabel {
    final owned = equipped;
    if (owned == null) {
      return 'Emplacement ${slot.label} vide';
    }
    return 'Emplacement ${slot.label} : ${owned.item.name}, niveau ${owned.level}';
  }

  @override
  Widget build(BuildContext context) {
    final owned = equipped;
    final borderRadius = BorderRadius.circular(HubStyle.panelRadius);
    return Semantics(
      button: owned != null,
      label: _semanticLabel,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: owned == null ? null : onTap,
          borderRadius: borderRadius,
          child: Ink(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
            decoration: HubStyle.panelDecoration(),
            child: Column(
              children: [
                Text(slot.label, style: HubStyle.title(fontSize: 14)),
                const SizedBox(height: 8),
                if (owned == null)
                  _EmptySlot(slot: slot, side: _frameSide)
                else
                  RarityItemFrame(
                    item: owned.item,
                    side: _frameSide,
                    level: owned.level,
                  ),
                const SizedBox(height: 12),
                Text(
                  owned?.item.name ?? 'Vide',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: HubStyle.body(
                    fontSize: 12,
                    color: owned == null
                        ? HubStyle.mutedText
                        : HubStyle.rarityColor(owned.item.rarity),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.slot, required this.side});

  final EquipmentSlot slot;
  final double side;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        color: HubStyle.deepNavy,
        borderRadius: BorderRadius.circular(HubStyle.tileRadius),
        border: Border.all(color: HubStyle.panelBorder, width: 2),
      ),
      child: Icon(slot.icon, size: side * 0.45, color: HubStyle.locked),
    );
  }
}
