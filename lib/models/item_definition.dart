import 'dart:ui';

import 'stat_modifiers.dart';

enum EquipmentSlot {
  attack('Attaque'),
  defense('Défense'),
  accessory('Accessoire');

  const EquipmentSlot(this.label);

  final String label;
}

enum ItemRarity {
  common('Commun', Color(0xFFB8B8D0)),
  rare('Rare', Color(0xFF4AB8FF)),
  epic('Épique', Color(0xFFC060F0)),
  legendary('Légendaire', Color(0xFFFFD040));

  const ItemRarity(this.label, this.color);

  final String label;
  final Color color;
}

sealed class ItemDefinition {
  const ItemDefinition({
    required this.id,
    required this.name,
    required this.spriteName,
    required this.rarity,
    required this.price,
  });

  static const _spriteBaseUrl =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items';

  final String id;
  final String name;
  final String spriteName;
  final ItemRarity rarity;
  final int price;

  String get spriteUrl => '$_spriteBaseUrl/$spriteName.png';

  bool get isForSale => price > 0;

  List<String> describe();
}

final class EquipmentItem extends ItemDefinition {
  const EquipmentItem({
    required super.id,
    required super.name,
    required super.spriteName,
    required super.rarity,
    required super.price,
    required this.slot,
    required this.modifiers,
  });

  static const maxLevel = 10;
  static const _levelGrowth = 0.15;
  static const _minUpgradeBaseCost = 50;

  final EquipmentSlot slot;
  final StatModifiers modifiers;

  StatModifiers modifiersAtLevel(int level) =>
      modifiers.scaledBy(1 + (level.clamp(1, maxLevel) - 1) * _levelGrowth);

  int upgradeCost(int currentLevel) =>
      (price < _minUpgradeBaseCost ? _minUpgradeBaseCost : price) *
      currentLevel;

  @override
  List<String> describe() => describeAtLevel(1);

  List<String> describeAtLevel(int level) {
    final effects = modifiersAtLevel(level).describe();
    return effects.isEmpty ? ['Aucun bonus'] : effects;
  }
}

final class ConsumableItem extends ItemDefinition {
  const ConsumableItem({
    required super.id,
    required super.name,
    required super.spriteName,
    required super.rarity,
    required super.price,
    this.healAmount = 0,
    this.boost,
    this.boostDuration = 0,
  }) : assert(boost == null || boostDuration > 0);

  static const fullHeal = 9999;

  final int healAmount;
  final StatModifiers? boost;
  final double boostDuration;

  @override
  List<String> describe() {
    final boostEffects = boost?.describe() ?? const [];
    return [
      if (healAmount >= fullHeal) 'Soin complet',
      if (healAmount > 0 && healAmount < fullHeal) 'Soigne $healAmount PV',
      for (final effect in boostEffects)
        '$effect pendant ${boostDuration.round()} s',
    ];
  }
}
