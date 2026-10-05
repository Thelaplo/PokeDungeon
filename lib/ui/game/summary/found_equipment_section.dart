import 'package:flutter/material.dart';

import '../../../models/item_definition.dart';
import '../../hub/common/rarity_item_frame.dart';
import '../../hub/hub_style.dart';

class FoundEquipmentSection extends StatelessWidget {
  const FoundEquipmentSection({required this.foundEquipment, super.key});

  static const _frameSide = 58.0;
  static const _itemWidth = 84.0;

  final List<EquipmentItem> foundEquipment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Objets trouvés', style: HubStyle.title(fontSize: 18)),
        const SizedBox(height: 8),
        if (foundEquipment.isEmpty)
          Text(
            'Aucun objet cette fois-ci.',
            style: HubStyle.body(color: HubStyle.mutedText),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: [
            for (final item in foundEquipment)
              SizedBox(
                width: _itemWidth,
                child: Column(
                  children: [
                    RarityItemFrame(item: item, side: _frameSide),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: HubStyle.body(
                        fontSize: 11,
                        color: HubStyle.rarityColor(item.rarity),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
