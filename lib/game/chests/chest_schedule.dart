import 'dart:math';

import '../../models/chapter.dart';

abstract final class ChestSchedule {
  static const guaranteedRooms = {3, 7};
  static const randomChestChance = 0.3;

  static bool hasChestAfter({
    required int clearedRoom,
    required Chapter chapter,
    required Random random,
  }) {
    if (chapter.isFinalBossRoom(clearedRoom)) {
      return false;
    }
    if (guaranteedRooms.contains(clearedRoom)) {
      return true;
    }
    return random.nextDouble() < randomChestChance;
  }
}
