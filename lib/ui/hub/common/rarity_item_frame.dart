import 'package:flutter/material.dart';

import '../../../models/item_definition.dart';
import '../hub_style.dart';

class RarityItemFrame extends StatelessWidget {
  const RarityItemFrame({
    required this.item,
    this.side = 64,
    this.level,
    this.isEquipped = false,
    super.key,
  });

  static const _spriteRatio = 0.72;
  static const _equippedBadgeSide = 20.0;

  final ItemDefinition item;
  final double side;
  final int? level;
  final bool isEquipped;

  @override
  Widget build(BuildContext context) {
    final itemLevel = level;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: side,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: HubStyle.rarityGradient(item.rarity),
                  borderRadius: BorderRadius.circular(HubStyle.tileRadius),
                  border: Border.all(color: HubStyle.navy, width: 2),
                  boxShadow: const [
                    BoxShadow(color: HubStyle.deepNavy, offset: Offset(0, 3)),
                  ],
                ),
                alignment: Alignment.center,
                child: Image.network(
                  item.spriteUrl,
                  width: side * _spriteRatio,
                  height: side * _spriteRatio,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.inventory_2_rounded,
                    color: HubStyle.white,
                    size: side * 0.45,
                  ),
                ),
              ),
            ),
            if (itemLevel != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: -6,
                child: Center(child: _LevelCapsule(level: itemLevel)),
              ),
            if (isEquipped)
              const Positioned(top: -6, right: -6, child: _EquippedBadge()),
          ],
        ),
      ),
    );
  }
}

class _LevelCapsule extends StatelessWidget {
  const _LevelCapsule({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: HubStyle.deepNavy.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HubStyle.panelBorder),
      ),
      child: Text(
        'Nv.$level',
        style: HubStyle.plainTitle(fontSize: 11, color: HubStyle.white),
      ),
    );
  }
}

class _EquippedBadge extends StatelessWidget {
  const _EquippedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: RarityItemFrame._equippedBadgeSide,
      height: RarityItemFrame._equippedBadgeSide,
      decoration: BoxDecoration(
        color: HubStyle.success,
        shape: BoxShape.circle,
        border: Border.all(color: HubStyle.navy, width: 2),
      ),
      child: const Icon(Icons.check_rounded, size: 13, color: HubStyle.white),
    );
  }
}
