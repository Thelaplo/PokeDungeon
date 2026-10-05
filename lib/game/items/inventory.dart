import 'package:flutter/foundation.dart';

import '../../models/item_definition.dart';
import '../../models/run_config.dart';
import '../../models/stat_modifiers.dart';
import 'item_catalog.dart';

class Inventory extends ChangeNotifier {
  Inventory({
    this.loadout = EquipmentLoadout.empty,
    Map<ConsumableItem, int> startingConsumables = const {},
  }) {
    for (final MapEntry(key: item, value: count)
        in startingConsumables.entries) {
      if (count > 0) {
        _consumables[item] = count;
      }
    }
  }

  final EquipmentLoadout loadout;
  final Map<ConsumableItem, int> _consumables = {};

  Map<EquipmentSlot, OwnedEquipment> get equipped =>
      Map.unmodifiable(loadout.equipped);

  Iterable<StatModifiers> get equipmentModifiers => loadout.modifiers;

  Iterable<EquipmentItem> get equippedItems =>
      loadout.equipped.values.map((owned) => owned.item);

  Map<ConsumableItem, int> get consumables {
    final catalogOrder = ItemCatalog.consumables.toList();
    final ownedItems =
        _consumables.keys.where((item) => countOf(item) > 0).toList()..sort(
          (first, second) => _catalogRank(
            catalogOrder,
            first,
          ).compareTo(_catalogRank(catalogOrder, second)),
        );
    return Map.unmodifiable({
      for (final item in ownedItems) item: countOf(item),
    });
  }

  bool get hasConsumables => _consumables.values.any((count) => count > 0);

  OwnedEquipment? equippedIn(EquipmentSlot slot) => loadout.equipped[slot];

  int countOf(ConsumableItem item) => _consumables[item] ?? 0;

  void addConsumable(ConsumableItem item) {
    _consumables[item] = countOf(item) + 1;
    notifyListeners();
  }

  bool consume(ConsumableItem item) {
    final count = countOf(item);
    if (count == 0) {
      return false;
    }
    _consumables[item] = count - 1;
    notifyListeners();
    return true;
  }

  static int _catalogRank(
    List<ConsumableItem> catalogOrder,
    ConsumableItem item,
  ) {
    final index = catalogOrder.indexOf(item);
    return index < 0 ? catalogOrder.length : index;
  }
}
