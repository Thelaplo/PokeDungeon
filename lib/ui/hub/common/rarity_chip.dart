import 'package:flutter/material.dart';

import '../../../models/item_definition.dart';
import '../hub_style.dart';

class RarityChip extends StatelessWidget {
  const RarityChip({required this.rarity, super.key});

  final ItemRarity rarity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        gradient: HubStyle.rarityGradient(rarity),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HubStyle.navy, width: 1.5),
      ),
      child: Text(rarity.label, style: HubStyle.title(fontSize: 13)),
    );
  }
}
