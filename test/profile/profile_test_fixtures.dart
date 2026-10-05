import 'dart:math';

import 'package:poke_dungeon/models/item_definition.dart';
import 'package:poke_dungeon/models/run_result.dart';
import 'package:poke_dungeon/profile/player_profile.dart';
import 'package:poke_dungeon/profile/profile_state.dart';
import 'package:poke_dungeon/profile/profile_storage.dart';

final testToday = DateTime(2026, 10, 5, 14, 30);

class InMemoryProfileStorage implements ProfileStorage {
  String? savedProfile;
  int writeCount = 0;

  @override
  String? read() => savedProfile;

  @override
  Future<void> write(String encodedProfile) async {
    savedProfile = encodedProfile;
    writeCount++;
  }
}

class ScriptedRandom implements Random {
  ScriptedRandom(this._values);

  final List<int> _values;
  int _nextIndex = 0;

  @override
  int nextInt(int max) {
    final value = _values[_nextIndex % _values.length];
    _nextIndex++;
    return value % max;
  }

  @override
  double nextDouble() => 0;

  @override
  bool nextBool() => false;
}

PlayerProfile buildProfile({
  ProfileState? state,
  InMemoryProfileStorage? storage,
  DateTime Function()? clock,
  Random? random,
}) => PlayerProfile(
  storage: storage ?? InMemoryProfileStorage(),
  state: state ?? ProfileState.fresh(testToday),
  clock: clock ?? () => testToday,
  random: random,
);

RunResult buildRunResult({
  int chapterNumber = 1,
  int roomsCleared = 0,
  bool isVictory = false,
  int coinsEarned = 0,
  int enemiesDefeated = 0,
  int bossesDefeated = 0,
  bool isDailyEventDefeated = false,
  int consumablesUsed = 0,
  List<EquipmentItem> foundEquipment = const [],
  Map<ConsumableItem, int> unusedConsumables = const {},
}) => RunResult(
  chapterNumber: chapterNumber,
  roomsCleared: roomsCleared,
  isVictory: isVictory,
  score: 0,
  coinsEarned: coinsEarned,
  enemiesDefeated: enemiesDefeated,
  bossesDefeated: bossesDefeated,
  isDailyEventDefeated: isDailyEventDefeated,
  consumablesUsed: consumablesUsed,
  foundEquipment: foundEquipment,
  unusedConsumables: unusedConsumables,
);
