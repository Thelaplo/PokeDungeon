import 'package:flutter/material.dart';

import '../hub_style.dart';

class EquipmentEffectsColumn extends StatelessWidget {
  const EquipmentEffectsColumn({
    required this.title,
    required this.effects,
    required this.effectColor,
    super.key,
  });

  final String title;
  final List<String> effects;
  final Color effectColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HubStyle.deepNavy.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: HubStyle.title(fontSize: 14)),
          const SizedBox(height: 6),
          for (final effect in effects)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                effect,
                style: HubStyle.body(fontSize: 12, color: effectColor),
              ),
            ),
        ],
      ),
    );
  }
}
