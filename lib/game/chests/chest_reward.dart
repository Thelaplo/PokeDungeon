import '../../models/item_definition.dart';

class ChestReward {
  const ChestReward({required this.coins, this.consumable, this.equipment});

  final int coins;
  final ConsumableItem? consumable;
  final EquipmentItem? equipment;

  bool get hasEquipment => equipment != null;

  String describe() =>
      ['Coffre : +$coins ₽', ?consumable?.name, ?equipment?.name].join(' · ');
}
