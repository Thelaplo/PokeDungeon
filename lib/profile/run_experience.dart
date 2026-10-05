import '../models/run_result.dart';

abstract final class RunExperience {
  static const xpPerRoomCleared = 20;
  static const xpPerBossDefeated = 60;
  static const xpForVictory = 250;
  static const xpPerEnemyDefeated = 2;

  static int earnedFrom(RunResult result) =>
      result.roomsCleared * xpPerRoomCleared +
      result.bossesDefeated * xpPerBossDefeated +
      (result.isVictory ? xpForVictory : 0) +
      result.enemiesDefeated * xpPerEnemyDefeated;
}
