import 'package:flutter/material.dart';

import '../../../models/item_definition.dart';
import '../../hub/common/rarity_item_frame.dart';
import '../../hub/hub_style.dart';

class GameItemTile extends StatelessWidget {
  const GameItemTile({
    required this.item,
    required this.caption,
    required this.effects,
    this.trailing,
    this.level,
    super.key,
  });

  static const _tileColor = Color(0x6608181E);

  final ItemDefinition item;
  final String caption;
  final List<String> effects;
  final Widget? trailing;
  final int? level;

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
      decoration: BoxDecoration(
        color: _tileColor,
        borderRadius: BorderRadius.circular(HubStyle.tileRadius),
        border: Border.all(
          color: HubStyle.rarityColor(item.rarity).withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          RarityItemFrame(item: item, side: 54, level: level),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: HubStyle.title(
                    fontSize: 16,
                    color: HubStyle.rarityColor(item.rarity),
                  ),
                ),
                Text(
                  caption,
                  style: HubStyle.body(fontSize: 11, color: HubStyle.mutedText),
                ),
                const SizedBox(height: 4),
                Text(effects.join('\n'), style: HubStyle.body(fontSize: 12)),
              ],
            ),
          ),
          if (trailingWidget != null) ...[
            const SizedBox(width: 8),
            trailingWidget,
          ],
        ],
      ),
    );
  }
}
