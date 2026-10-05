import 'package:flutter/material.dart';

import '../../../models/pokemon_type.dart';
import '../hub_style.dart';

class TypeBadge extends StatelessWidget {
  const TypeBadge({required this.type, this.isCompact = false, super.key});

  static const _lightenAmount = 0.2;
  static const _darkenAmount = 0.25;

  final PokemonType type;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    return Semantics(
      label: 'Type ${type.label}',
      excludeSemantics: true,
      child: Container(
        padding: isCompact
            ? const EdgeInsets.symmetric(horizontal: 7, vertical: 1)
            : const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(color, Colors.white, _lightenAmount) ?? color,
              Color.lerp(color, Colors.black, _darkenAmount) ?? color,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: HubStyle.navy, width: 1.5),
        ),
        child: Text(
          type.label,
          maxLines: 1,
          style: HubStyle.title(fontSize: isCompact ? 11 : 13),
        ),
      ),
    );
  }
}
