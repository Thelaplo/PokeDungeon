import '../game/heroes/hero_catalog.dart';
import '../game/items/item_catalog.dart';
import '../models/daily_quest.dart';
import '../models/hero_definition.dart';
import '../models/item_definition.dart';
import '../quests/daily_quest_board.dart';
import 'trainer_progress.dart';

class ProfileState {
  const ProfileState({
    required this.coins,
    required this.gems,
    required this.trainer,
    required this.highestUnlockedChapter,
    required this.bestRoomsByChapter,
    required this.completedChapters,
    required this.equipmentLevels,
    required this.equippedIds,
    required this.consumableCounts,
    required this.questBoard,
    required this.selectedHeroId,
    required this.purchasedHeroIds,
    required this.acknowledgedHeroIds,
  });

  factory ProfileState.fresh(DateTime today) => ProfileState(
    coins: 0,
    gems: 0,
    trainer: TrainerProgress.initial,
    highestUnlockedChapter: firstChapterNumber,
    bestRoomsByChapter: const {},
    completedChapters: const {},
    equipmentLevels: {ItemCatalog.silkScarf.id: newEquipmentLevel},
    equippedIds: {ItemCatalog.silkScarf.slot: ItemCatalog.silkScarf.id},
    consumableCounts: {ItemCatalog.potion.id: startingPotionCount},
    questBoard: DailyQuestBoard.forDay(today),
    selectedHeroId: HeroCatalog.trainer.id,
    purchasedHeroIds: const {},
    acknowledgedHeroIds: starterHeroIds,
  );

  static Set<String> get starterHeroIds => {
    for (final hero in HeroCatalog.all)
      if (hero.unlock.kind == HeroUnlockKind.starter) hero.id,
  };

  static const firstChapterNumber = 1;
  static const newEquipmentLevel = 1;
  static const startingPotionCount = 2;
  static const duplicateRefundDivisor = 2;

  final int coins;
  final int gems;
  final TrainerProgress trainer;
  final int highestUnlockedChapter;
  final Map<int, int> bestRoomsByChapter;
  final Set<int> completedChapters;
  final Map<String, int> equipmentLevels;
  final Map<EquipmentSlot, String> equippedIds;
  final Map<String, int> consumableCounts;
  final DailyQuestBoard questBoard;
  final String selectedHeroId;
  final Set<String> purchasedHeroIds;
  final Set<String> acknowledgedHeroIds;

  bool isHeroUnlocked(HeroDefinition hero) => switch (hero.unlock.kind) {
    HeroUnlockKind.starter => true,
    HeroUnlockKind.trainerLevel => trainer.level >= hero.unlock.value,
    HeroUnlockKind.chapterCompleted => completedChapters.contains(
      hero.unlock.value,
    ),
    HeroUnlockKind.gems => purchasedHeroIds.contains(hero.id),
  };

  HeroDefinition get selectedHero {
    final hero = HeroCatalog.byId(selectedHeroId);
    if (hero == null || !isHeroUnlocked(hero)) return HeroCatalog.trainer;
    return hero;
  }

  bool owns(EquipmentItem item) => equipmentLevels.containsKey(item.id);

  int levelOf(EquipmentItem item) => equipmentLevels[item.id] ?? 0;

  bool isEquipped(EquipmentItem item) => equippedIds[item.slot] == item.id;

  ProfileState copyWith({
    int? coins,
    int? gems,
    TrainerProgress? trainer,
    int? highestUnlockedChapter,
    Map<int, int>? bestRoomsByChapter,
    Set<int>? completedChapters,
    Map<String, int>? equipmentLevels,
    Map<EquipmentSlot, String>? equippedIds,
    Map<String, int>? consumableCounts,
    DailyQuestBoard? questBoard,
    String? selectedHeroId,
    Set<String>? purchasedHeroIds,
    Set<String>? acknowledgedHeroIds,
  }) => ProfileState(
    coins: coins ?? this.coins,
    gems: gems ?? this.gems,
    trainer: trainer ?? this.trainer,
    highestUnlockedChapter:
        highestUnlockedChapter ?? this.highestUnlockedChapter,
    bestRoomsByChapter: bestRoomsByChapter ?? this.bestRoomsByChapter,
    completedChapters: completedChapters ?? this.completedChapters,
    equipmentLevels: equipmentLevels ?? this.equipmentLevels,
    equippedIds: equippedIds ?? this.equippedIds,
    consumableCounts: consumableCounts ?? this.consumableCounts,
    questBoard: questBoard ?? this.questBoard,
    selectedHeroId: selectedHeroId ?? this.selectedHeroId,
    purchasedHeroIds: purchasedHeroIds ?? this.purchasedHeroIds,
    acknowledgedHeroIds: acknowledgedHeroIds ?? this.acknowledgedHeroIds,
  );

  ProfileState withPurchasedHero(HeroDefinition hero) => copyWith(
    gems: gems - hero.unlock.value,
    purchasedHeroIds: {...purchasedHeroIds, hero.id},
    acknowledgedHeroIds: {...acknowledgedHeroIds, hero.id},
  );

  ProfileState withAcknowledgedHeroes(Iterable<HeroDefinition> heroes) =>
      copyWith(
        acknowledgedHeroIds: {
          ...acknowledgedHeroIds,
          for (final hero in heroes) hero.id,
        },
      );

  ProfileState earning({int coins = 0, int gems = 0, int xp = 0}) => copyWith(
    coins: this.coins + coins,
    gems: this.gems + gems,
    trainer: trainer.addXp(xp),
  );

  ProfileState withReward(QuestReward reward) =>
      earning(coins: reward.coins, gems: reward.gems, xp: reward.xp);

  ProfileState spendingCoins(int amount) => copyWith(coins: coins - amount);

  ProfileState spendingGems(int amount) => copyWith(gems: gems - amount);

  ProfileState withNewEquipment(EquipmentItem item) {
    final isSlotFree = !equippedIds.containsKey(item.slot);
    return copyWith(
      equipmentLevels: {...equipmentLevels, item.id: newEquipmentLevel},
      equippedIds: isSlotFree
          ? {...equippedIds, item.slot: item.id}
          : equippedIds,
    );
  }

  ProfileState withFoundEquipment(EquipmentItem item) {
    if (!owns(item)) return withNewEquipment(item);
    return earning(coins: item.price ~/ duplicateRefundDivisor);
  }

  ProfileState withEquipmentLevel(EquipmentItem item, int level) =>
      copyWith(equipmentLevels: {...equipmentLevels, item.id: level});

  ProfileState withEquipped(EquipmentItem item) =>
      copyWith(equippedIds: {...equippedIds, item.slot: item.id});

  ProfileState withoutEquipped(EquipmentSlot slot) =>
      copyWith(equippedIds: {...equippedIds}..remove(slot));

  ProfileState withConsumableAdded(ConsumableItem item) => copyWith(
    consumableCounts: {
      ...consumableCounts,
      item.id: (consumableCounts[item.id] ?? 0) + 1,
    },
  );

  ProfileState withConsumables(Map<ConsumableItem, int> stock) => copyWith(
    consumableCounts: {
      for (final entry in stock.entries)
        if (entry.value > 0) entry.key.id: entry.value,
    },
  );

  ProfileState withBestRoom(int chapterNumber, int roomsCleared) {
    final previousBest = bestRoomsByChapter[chapterNumber] ?? 0;
    if (roomsCleared <= previousBest) return this;
    return copyWith(
      bestRoomsByChapter: {...bestRoomsByChapter, chapterNumber: roomsCleared},
    );
  }

  ProfileState withCompletedChapter(
    int chapterNumber, {
    required int chapterCount,
  }) {
    final nextChapter = chapterNumber + 1;
    final unlockedChapter = nextChapter > chapterCount
        ? chapterCount
        : nextChapter;
    return copyWith(
      completedChapters: {...completedChapters, chapterNumber},
      highestUnlockedChapter: unlockedChapter > highestUnlockedChapter
          ? unlockedChapter
          : highestUnlockedChapter,
    );
  }
}
