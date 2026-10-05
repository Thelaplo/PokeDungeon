import 'dart:convert';

import '../game/chapters/chapter_catalog.dart';
import '../game/heroes/hero_catalog.dart';
import '../models/item_definition.dart';
import '../quests/daily_quest_board.dart';
import 'item_lookup.dart';
import 'profile_state.dart';
import 'trainer_progress.dart';

abstract final class ProfileCodec {
  static const currentVersion = 1;
  static const _versionField = 'version';
  static const _coinsField = 'coins';
  static const _gemsField = 'gems';
  static const _trainerLevelField = 'trainerLevel';
  static const _xpIntoLevelField = 'xpIntoLevel';
  static const _highestUnlockedChapterField = 'highestUnlockedChapter';
  static const _bestRoomsField = 'bestRooms';
  static const _completedChaptersField = 'completedChapters';
  static const _equipmentLevelsField = 'equipmentLevels';
  static const _equippedField = 'equipped';
  static const _consumablesField = 'consumables';
  static const _dailyQuestsField = 'dailyQuests';
  static const _selectedHeroField = 'selectedHero';
  static const _purchasedHeroesField = 'purchasedHeroes';
  static const _acknowledgedHeroesField = 'acknowledgedHeroes';

  static String encode(ProfileState state) => jsonEncode({
    _versionField: currentVersion,
    _coinsField: state.coins,
    _gemsField: state.gems,
    _trainerLevelField: state.trainer.level,
    _xpIntoLevelField: state.trainer.xpIntoLevel,
    _highestUnlockedChapterField: state.highestUnlockedChapter,
    _bestRoomsField: {
      for (final entry in state.bestRoomsByChapter.entries)
        '${entry.key}': entry.value,
    },
    _completedChaptersField: state.completedChapters.toList(),
    _equipmentLevelsField: state.equipmentLevels,
    _equippedField: {
      for (final entry in state.equippedIds.entries)
        entry.key.name: entry.value,
    },
    _consumablesField: state.consumableCounts,
    _dailyQuestsField: state.questBoard.toJson(),
    _selectedHeroField: state.selectedHeroId,
    _purchasedHeroesField: state.purchasedHeroIds.toList(),
    _acknowledgedHeroesField: state.acknowledgedHeroIds.toList(),
  });

  static ProfileState decode(String? encodedProfile, DateTime today) {
    if (encodedProfile == null) return ProfileState.fresh(today);
    try {
      final Object? json = jsonDecode(encodedProfile);
      return _decodeFields(json as Map<String, Object?>, today);
    } on FormatException {
      return ProfileState.fresh(today);
    } on TypeError {
      return ProfileState.fresh(today);
    }
  }

  static ProfileState _decodeFields(Map<String, Object?> json, DateTime today) {
    if (json[_versionField] != currentVersion) return ProfileState.fresh(today);
    final equipmentLevels = _decodeEquipmentLevels(
      json[_equipmentLevelsField] as Map<String, Object?>,
    );
    return ProfileState(
      coins: _nonNegative(json[_coinsField] as int),
      gems: _nonNegative(json[_gemsField] as int),
      trainer: _decodeTrainer(json),
      highestUnlockedChapter: _clampChapter(
        json[_highestUnlockedChapterField] as int,
      ),
      bestRoomsByChapter: _decodeBestRooms(
        json[_bestRoomsField] as Map<String, Object?>,
      ),
      completedChapters: _decodeCompletedChapters(
        json[_completedChaptersField] as List<Object?>,
      ),
      equipmentLevels: equipmentLevels,
      equippedIds: _decodeEquipped(
        json[_equippedField] as Map<String, Object?>,
        equipmentLevels,
      ),
      consumableCounts: _decodeConsumables(
        json[_consumablesField] as Map<String, Object?>,
      ),
      questBoard: DailyQuestBoard.fromJson(
        json[_dailyQuestsField] as Map<String, Object?>,
        today,
      ),
      selectedHeroId: _decodeSelectedHero(json[_selectedHeroField] as String?),
      purchasedHeroIds: _decodeHeroIds(
        json[_purchasedHeroesField] as List<Object?>?,
        fallback: const {},
      ),
      acknowledgedHeroIds: _decodeHeroIds(
        json[_acknowledgedHeroesField] as List<Object?>?,
        fallback: ProfileState.starterHeroIds,
      ),
    );
  }

  static String _decodeSelectedHero(String? heroId) {
    if (heroId == null) return HeroCatalog.trainer.id;
    return HeroCatalog.byId(heroId)?.id ?? HeroCatalog.trainer.id;
  }

  static Set<String> _decodeHeroIds(
    List<Object?>? json, {
    required Set<String> fallback,
  }) {
    if (json == null) return fallback;
    return {
      for (final heroId in json)
        if (HeroCatalog.byId(heroId as String) != null) heroId,
    };
  }

  static TrainerProgress _decodeTrainer(Map<String, Object?> json) {
    final level = json[_trainerLevelField] as int;
    final xpIntoLevel = json[_xpIntoLevelField] as int;
    if (level < TrainerProgress.initial.level) return TrainerProgress.initial;
    return TrainerProgress(
      level: level,
      xpIntoLevel: _nonNegative(xpIntoLevel),
    );
  }

  static Map<int, int> _decodeBestRooms(Map<String, Object?> json) => {
    for (final entry in json.entries)
      int.parse(entry.key): _nonNegative(entry.value as int),
  };

  static Set<int> _decodeCompletedChapters(List<Object?> json) => {
    for (final chapterNumber in json) chapterNumber as int,
  };

  static Map<String, int> _decodeEquipmentLevels(Map<String, Object?> json) => {
    for (final entry in json.entries)
      if (ItemLookup.equipmentById(entry.key) != null)
        entry.key: (entry.value as int).clamp(
          ProfileState.newEquipmentLevel,
          EquipmentItem.maxLevel,
        ),
  };

  static Map<EquipmentSlot, String> _decodeEquipped(
    Map<String, Object?> json,
    Map<String, int> equipmentLevels,
  ) {
    final slotsByName = EquipmentSlot.values.asNameMap();
    final equipped = <EquipmentSlot, String>{};
    for (final entry in json.entries) {
      final slot = slotsByName[entry.key];
      final itemId = entry.value as String;
      final item = ItemLookup.equipmentById(itemId);
      final isValid =
          slot != null &&
          item != null &&
          item.slot == slot &&
          equipmentLevels.containsKey(itemId);
      if (isValid) equipped[slot] = itemId;
    }
    return equipped;
  }

  static Map<String, int> _decodeConsumables(Map<String, Object?> json) => {
    for (final entry in json.entries)
      if (ItemLookup.consumableById(entry.key) != null &&
          (entry.value as int) > 0)
        entry.key: entry.value as int,
  };

  static int _clampChapter(int chapterNumber) => chapterNumber.clamp(
    ProfileState.firstChapterNumber,
    ChapterCatalog.all.length,
  );

  static int _nonNegative(int value) => value < 0 ? 0 : value;
}
