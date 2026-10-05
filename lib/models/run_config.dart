import '../game/heroes/hero_catalog.dart';
import 'chapter.dart';
import 'hero_definition.dart';
import 'item_definition.dart';
import 'stat_modifiers.dart';

class OwnedEquipment {
  const OwnedEquipment({required this.item, required this.level});

  final EquipmentItem item;
  final int level;

  StatModifiers get modifiers => item.modifiersAtLevel(level);
}

class EquipmentLoadout {
  const EquipmentLoadout(this.equipped);

  static const empty = EquipmentLoadout({});

  final Map<EquipmentSlot, OwnedEquipment> equipped;

  Iterable<StatModifiers> get modifiers =>
      equipped.values.map((owned) => owned.modifiers);
}

class RunConfig {
  const RunConfig({
    required this.chapter,
    required this.loadout,
    this.startingConsumables = const {},
    this.hero = HeroCatalog.trainer,
  });

  final Chapter chapter;
  final EquipmentLoadout loadout;
  final Map<ConsumableItem, int> startingConsumables;
  final HeroDefinition hero;
}
