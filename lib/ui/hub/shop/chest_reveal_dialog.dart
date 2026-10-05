import 'package:flutter/material.dart';

import '../../../models/item_definition.dart';
import '../common/hub_button.dart';
import '../common/hub_dialog_frame.dart';
import '../common/rarity_chip.dart';
import '../common/rarity_item_frame.dart';
import '../hub_style.dart';

class ChestRevealDialog extends StatelessWidget {
  const ChestRevealDialog({
    required this.item,
    required this.chestLabel,
    super.key,
  });

  static const _frameSide = 112.0;
  static const _revealDuration = Duration(milliseconds: 450);

  final EquipmentItem item;
  final String chestLabel;

  @override
  Widget build(BuildContext context) {
    final rarityColor = HubStyle.rarityColor(item.rarity);
    return HubDialogFrame(
      borderColor: rarityColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(chestLabel, style: HubStyle.body(color: HubStyle.mutedText)),
          Semantics(
            header: true,
            liveRegion: true,
            child: Text('Tu as obtenu !', style: HubStyle.title(fontSize: 28)),
          ),
          const SizedBox(height: 18),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.4, end: 1),
            duration: _revealDuration,
            curve: Curves.elasticOut,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: RarityItemFrame(item: item, side: _frameSide, level: 1),
          ),
          const SizedBox(height: 18),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: HubStyle.title(fontSize: 24, color: rarityColor),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RarityChip(rarity: item.rarity),
              const SizedBox(width: 8),
              Text(
                item.slot.label,
                style: HubStyle.body(color: HubStyle.mutedText),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final effect in item.describeAtLevel(1))
            Text(effect, style: HubStyle.body(color: HubStyle.success)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: HubButton(
              label: 'SUPER !',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
