import 'package:flutter/material.dart';

import '../../../models/run_config.dart';
import '../common/rarity_item_frame.dart';
import '../hub_style.dart';

class OwnedEquipmentTile extends StatelessWidget {
  const OwnedEquipmentTile({
    required this.owned,
    required this.isEquipped,
    required this.onTap,
    super.key,
  });

  static const _frameSide = 60.0;

  final OwnedEquipment owned;
  final bool isEquipped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${owned.item.name}, ${owned.item.rarity.label}, niveau ${owned.level}'
          '${isEquipped ? ', équipé' : ''}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HubStyle.tileRadius),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              RarityItemFrame(
                item: owned.item,
                side: _frameSide,
                level: owned.level,
                isEquipped: isEquipped,
              ),
              const SizedBox(height: 10),
              Text(
                owned.item.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: HubStyle.body(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
