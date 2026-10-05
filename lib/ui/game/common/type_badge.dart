import 'package:flutter/material.dart';

import '../../../models/pokemon_type.dart';
import '../../hub/hub_style.dart';

class TypeBadge extends StatelessWidget {
  const TypeBadge({required this.type, this.fontSize = 10, super.key});

  final PokemonType type;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Type ${type.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
        decoration: BoxDecoration(
          color: type.color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: HubStyle.navy, width: 1.5),
        ),
        child: Text(type.label, style: HubStyle.title(fontSize: fontSize)),
      ),
    );
  }
}
