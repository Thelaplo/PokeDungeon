import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/items/inventory.dart';
import 'package:poke_dungeon/game/items/item_catalog.dart';
import 'package:poke_dungeon/models/item_definition.dart';
import 'package:poke_dungeon/models/run_config.dart';

const loadout = EquipmentLoadout({
  EquipmentSlot.attack: OwnedEquipment(item: ItemCatalog.charcoal, level: 3),
  EquipmentSlot.defense: OwnedEquipment(item: ItemCatalog.hardStone, level: 1),
});

void main() {
  test('the run uses the loadout equipment', () {
    final inventory = Inventory(loadout: loadout);

    expect(inventory.equippedIn(EquipmentSlot.attack)?.level, 3);
    expect(inventory.equippedIn(EquipmentSlot.accessory), isNull);
    expect(inventory.equippedItems, [
      ItemCatalog.charcoal,
      ItemCatalog.hardStone,
    ]);
  });

  test('equipment modifiers are scaled by the owned level', () {
    final inventory = Inventory(loadout: loadout);
    final attackModifiers = inventory.equipmentModifiers.first;

    expect(
      attackModifiers.damageBonus,
      ItemCatalog.charcoal.modifiersAtLevel(3).damageBonus,
    );
    expect(attackModifiers.damageBonus, greaterThan(5));
  });

  test('an empty loadout gives no equipment', () {
    final inventory = Inventory();

    expect(inventory.equipped, isEmpty);
    expect(inventory.equipmentModifiers, isEmpty);
  });

  test('starting consumables fill the bag and skip empty stacks', () {
    final inventory = Inventory(
      startingConsumables: {ItemCatalog.potion: 2, ItemCatalog.xSpeed: 0},
    );

    expect(inventory.consumables, {ItemCatalog.potion: 2});
    expect(inventory.hasConsumables, isTrue);
  });

  test('consuming an item uses one and fails when none is left', () {
    final inventory = Inventory(startingConsumables: {ItemCatalog.potion: 1});

    expect(inventory.consume(ItemCatalog.potion), isTrue);
    expect(inventory.consume(ItemCatalog.potion), isFalse);
    expect(inventory.countOf(ItemCatalog.potion), 0);
    expect(inventory.consumables, isEmpty);
    expect(inventory.hasConsumables, isFalse);
  });

  test('picked up consumables are added and notify listeners', () {
    final inventory = Inventory();
    var notificationCount = 0;
    inventory
      ..addListener(() => notificationCount++)
      ..addConsumable(ItemCatalog.superPotion)
      ..addConsumable(ItemCatalog.superPotion);

    expect(inventory.countOf(ItemCatalog.superPotion), 2);
    expect(notificationCount, 2);
  });

  test('consumables are listed in catalog order', () {
    final inventory = Inventory(
      startingConsumables: {
        ItemCatalog.xSpeed: 1,
        ItemCatalog.potion: 1,
        ItemCatalog.hyperPotion: 1,
      },
    );

    expect(inventory.consumables.keys, [
      ItemCatalog.potion,
      ItemCatalog.hyperPotion,
      ItemCatalog.xSpeed,
    ]);
  });

  test('the starting consumables map is never modified', () {
    final startingConsumables = {ItemCatalog.potion: 1};
    Inventory(startingConsumables: startingConsumables)
        .consume(ItemCatalog.potion);

    expect(startingConsumables, {ItemCatalog.potion: 1});
  });
}
