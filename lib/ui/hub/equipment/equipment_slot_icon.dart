import 'package:flutter/material.dart';

import '../../../models/item_definition.dart';

extension EquipmentSlotIcon on EquipmentSlot {
  IconData get icon => switch (this) {
    EquipmentSlot.attack => Icons.local_fire_department_rounded,
    EquipmentSlot.defense => Icons.shield_rounded,
    EquipmentSlot.accessory => Icons.diamond_rounded,
  };
}
