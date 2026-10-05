import '../../../models/chapter.dart';
import '../../../models/run_result.dart';

class RunRecap {
  const RunRecap({
    required this.chapter,
    required this.result,
    required this.coinsGained,
    required this.gemsGained,
    required this.previousTrainerLevel,
    required this.newTrainerLevel,
  });

  final Chapter chapter;
  final RunResult result;
  final int coinsGained;
  final int gemsGained;
  final int previousTrainerLevel;
  final int newTrainerLevel;

  bool get hasLeveledUp => newTrainerLevel > previousTrainerLevel;

  bool get hasFoundEquipment => result.foundEquipment.isNotEmpty;
}
