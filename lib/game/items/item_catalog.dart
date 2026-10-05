import '../../models/item_definition.dart';
import '../../models/stat_modifiers.dart';

abstract final class ItemCatalog {
  static const silkScarf = EquipmentItem(
    id: 'silk-scarf',
    name: 'Mouchoir Soie',
    spriteName: 'silk-scarf',
    rarity: ItemRarity.common,
    price: 0,
    slot: EquipmentSlot.attack,
    modifiers: StatModifiers(),
  );
  static const charcoal = EquipmentItem(
    id: 'charcoal',
    name: 'Charbon',
    spriteName: 'charcoal',
    rarity: ItemRarity.common,
    price: 60,
    slot: EquipmentSlot.attack,
    modifiers: StatModifiers(damageBonus: 5),
  );
  static const muscleBand = EquipmentItem(
    id: 'muscle-band',
    name: 'Bandeau Muscle',
    spriteName: 'muscle-band',
    rarity: ItemRarity.rare,
    price: 150,
    slot: EquipmentSlot.attack,
    modifiers: StatModifiers(damageBonus: 5, damagePercent: 0.2),
  );
  static const wideLens = EquipmentItem(
    id: 'wide-lens',
    name: 'Loupe',
    spriteName: 'wide-lens',
    rarity: ItemRarity.epic,
    price: 300,
    slot: EquipmentSlot.attack,
    modifiers: StatModifiers(extraProjectiles: 2, damagePercent: -0.2),
  );
  static const choiceBand = EquipmentItem(
    id: 'choice-band',
    name: 'Bandeau Choix',
    spriteName: 'choice-band',
    rarity: ItemRarity.epic,
    price: 320,
    slot: EquipmentSlot.attack,
    modifiers: StatModifiers(damagePercent: 0.5, fireRatePercent: -0.1),
  );
  static const lifeOrb = EquipmentItem(
    id: 'life-orb',
    name: 'Orbe Vie',
    spriteName: 'life-orb',
    rarity: ItemRarity.legendary,
    price: 520,
    slot: EquipmentSlot.attack,
    modifiers: StatModifiers(damagePercent: 0.4, extraProjectiles: 1),
  );

  static const hardStone = EquipmentItem(
    id: 'hard-stone',
    name: 'Pierre Dure',
    spriteName: 'hard-stone',
    rarity: ItemRarity.common,
    price: 70,
    slot: EquipmentSlot.defense,
    modifiers: StatModifiers(maxHpBonus: 20),
  );
  static const metalCoat = EquipmentItem(
    id: 'metal-coat',
    name: 'Peau Métal',
    spriteName: 'metal-coat',
    rarity: ItemRarity.rare,
    price: 160,
    slot: EquipmentSlot.defense,
    modifiers: StatModifiers(maxHpBonus: 35, damageReduction: 0.1),
  );
  static const dragonScale = EquipmentItem(
    id: 'dragon-scale',
    name: 'Écaille Draco',
    spriteName: 'dragon-scale',
    rarity: ItemRarity.epic,
    price: 300,
    slot: EquipmentSlot.defense,
    modifiers: StatModifiers(
      maxHpBonus: 60,
      damageReduction: 0.15,
      speedPercent: -0.05,
    ),
  );
  static const assaultVest = EquipmentItem(
    id: 'assault-vest',
    name: 'Veste de Combat',
    spriteName: 'assault-vest',
    rarity: ItemRarity.legendary,
    price: 480,
    slot: EquipmentSlot.defense,
    modifiers: StatModifiers(maxHpBonus: 80, damageReduction: 0.25),
  );

  static const magnet = EquipmentItem(
    id: 'magnet',
    name: 'Aimant',
    spriteName: 'magnet',
    rarity: ItemRarity.common,
    price: 60,
    slot: EquipmentSlot.accessory,
    modifiers: StatModifiers(magnetRadiusBonus: 130),
  );
  static const quickClaw = EquipmentItem(
    id: 'quick-claw',
    name: 'Vive Griffe',
    spriteName: 'quick-claw',
    rarity: ItemRarity.common,
    price: 80,
    slot: EquipmentSlot.accessory,
    modifiers: StatModifiers(fireRatePercent: 0.25),
  );
  static const choiceScarf = EquipmentItem(
    id: 'choice-scarf',
    name: 'Mouchoir Choix',
    spriteName: 'choice-scarf',
    rarity: ItemRarity.rare,
    price: 160,
    slot: EquipmentSlot.accessory,
    modifiers: StatModifiers(speedPercent: 0.3),
  );
  static const leftovers = EquipmentItem(
    id: 'leftovers',
    name: 'Restes',
    spriteName: 'leftovers',
    rarity: ItemRarity.rare,
    price: 220,
    slot: EquipmentSlot.accessory,
    modifiers: StatModifiers(regenPerSecond: 1.5),
  );
  static const shellBell = EquipmentItem(
    id: 'shell-bell',
    name: 'Grelot Coque',
    spriteName: 'shell-bell',
    rarity: ItemRarity.epic,
    price: 280,
    slot: EquipmentSlot.accessory,
    modifiers: StatModifiers(healOnHit: 2),
  );

  static const potion = ConsumableItem(
    id: 'potion',
    name: 'Potion',
    spriteName: 'potion',
    rarity: ItemRarity.common,
    price: 25,
    healAmount: 30,
  );
  static const superPotion = ConsumableItem(
    id: 'super-potion',
    name: 'Super Potion',
    spriteName: 'super-potion',
    rarity: ItemRarity.rare,
    price: 60,
    healAmount: 70,
  );
  static const hyperPotion = ConsumableItem(
    id: 'hyper-potion',
    name: 'Hyper Potion',
    spriteName: 'hyper-potion',
    rarity: ItemRarity.epic,
    price: 120,
    healAmount: ConsumableItem.fullHeal,
  );
  static const xAttack = ConsumableItem(
    id: 'x-attack',
    name: 'Attaque +',
    spriteName: 'x-attack',
    rarity: ItemRarity.rare,
    price: 80,
    boost: StatModifiers(damagePercent: 0.5),
    boostDuration: 20,
  );
  static const xSpeed = ConsumableItem(
    id: 'x-speed',
    name: 'Vitesse +',
    spriteName: 'x-speed',
    rarity: ItemRarity.rare,
    price: 70,
    boost: StatModifiers(speedPercent: 0.4, fireRatePercent: 0.2),
    boostDuration: 20,
  );

  static const List<ItemDefinition> all = [
    silkScarf,
    charcoal,
    muscleBand,
    wideLens,
    choiceBand,
    lifeOrb,
    hardStone,
    metalCoat,
    dragonScale,
    assaultVest,
    magnet,
    quickClaw,
    choiceScarf,
    leftovers,
    shellBell,
    potion,
    superPotion,
    hyperPotion,
    xAttack,
    xSpeed,
  ];

  static Iterable<EquipmentItem> get equipment =>
      all.whereType<EquipmentItem>();

  static Iterable<ConsumableItem> get consumables =>
      all.whereType<ConsumableItem>();
}
