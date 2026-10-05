import '../game/items/item_catalog.dart';
import '../models/item_definition.dart';

abstract final class ItemLookup {
  static final Map<String, EquipmentItem> _equipmentById = {
    for (final item in ItemCatalog.equipment) item.id: item,
  };
  static final Map<String, ConsumableItem> _consumablesById = {
    for (final item in ItemCatalog.consumables) item.id: item,
  };

  static EquipmentItem? equipmentById(String id) => _equipmentById[id];

  static ConsumableItem? consumableById(String id) => _consumablesById[id];
}
