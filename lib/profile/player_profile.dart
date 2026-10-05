import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../game/chapters/chapter_catalog.dart';
import '../game/heroes/hero_catalog.dart';
import '../models/daily_quest.dart';
import '../models/hero_definition.dart';
import '../models/item_definition.dart';
import '../models/run_config.dart';
import '../models/run_result.dart';
import '../quests/daily_quest_board.dart';
import 'chapter_locked_exception.dart';
import 'chest_roller.dart';
import 'chest_type.dart';
import 'hero_purchase_result.dart';
import 'item_lookup.dart';
import 'profile_codec.dart';
import 'profile_state.dart';
import 'profile_storage.dart';
import 'run_experience.dart';

export 'chapter_locked_exception.dart';
export 'chest_type.dart';
export 'hero_purchase_result.dart';

enum ShopPurchaseResult {
  purchased,
  notEnoughCoins,
  notEnoughGems,
  alreadyOwned,
}

enum UpgradeResult { upgraded, notEnoughCoins, maxLevelReached, notOwned }

typedef Clock = DateTime Function();

class PlayerProfile extends ChangeNotifier {
  PlayerProfile({
    required this._storage,
    required this._state,
    this._clock = DateTime.now,
    Random? random,
  }) : _chestRoller = ChestRoller(random ?? Random());

  static const chestGemCost = ChestType.pokeBallGemCost;

  final ProfileStorage _storage;
  final Clock _clock;
  final ChestRoller _chestRoller;
  ProfileState _state;

  static Future<PlayerProfile> load({
    ProfileStorage? storage,
    Clock clock = DateTime.now,
    Random? random,
  }) async {
    final resolvedStorage =
        storage ?? await SharedPreferencesProfileStorage.create();
    return PlayerProfile(
      storage: resolvedStorage,
      state: ProfileCodec.decode(resolvedStorage.read(), clock()),
      clock: clock,
      random: random,
    );
  }

  int get coins => _state.coins;

  int get gems => _state.gems;

  int get trainerLevel => _state.trainer.level;

  int get xpIntoLevel => _state.trainer.xpIntoLevel;

  int get xpForNextLevel => _state.trainer.xpForNextLevel;

  int get highestUnlockedChapter => _state.highestUnlockedChapter;

  bool get canOpenChest => canOpen(ChestType.pokeBall);

  bool canOpen(ChestType type) => gems >= type.gemCost;

  int bestRoomFor(int chapterNumber) =>
      _state.bestRoomsByChapter[chapterNumber] ?? 0;

  bool isChapterCompleted(int chapterNumber) =>
      _state.completedChapters.contains(chapterNumber);

  bool isChapterUnlocked(int chapterNumber) =>
      chapterNumber >= ProfileState.firstChapterNumber &&
      chapterNumber <= highestUnlockedChapter;

  List<OwnedEquipment> get ownedEquipment => List.unmodifiable([
    for (final entry in _state.equipmentLevels.entries)
      if (ItemLookup.equipmentById(entry.key) case final item?)
        OwnedEquipment(item: item, level: entry.value),
  ]);

  Map<EquipmentSlot, OwnedEquipment> get equipped => Map.unmodifiable({
    for (final entry in _state.equippedIds.entries)
      if (ItemLookup.equipmentById(entry.value) case final item?)
        entry.key: OwnedEquipment(item: item, level: _state.levelOf(item)),
  });

  Map<ConsumableItem, int> get consumables => Map.unmodifiable({
    for (final entry in _state.consumableCounts.entries)
      ?ItemLookup.consumableById(entry.key): entry.value,
  });

  EquipmentLoadout get loadout => EquipmentLoadout(equipped);

  List<DailyQuest> get dailyQuests => _todayQuestBoard.quests;

  QuestReward get dailyBonusReward => DailyQuestBoard.bonusReward;

  int get claimedQuestCount => _todayQuestBoard.claimedQuestCount;

  bool get canClaimDailyBonus => _todayQuestBoard.canClaimBonus;

  bool get isDailyBonusClaimed => _todayQuestBoard.isBonusClaimed;

  HeroDefinition get selectedHero => _state.selectedHero;

  List<HeroDefinition> get newlyUnlockedHeroes => List.unmodifiable(
    HeroCatalog.all.where(
      (hero) =>
          isHeroUnlocked(hero) && !_state.acknowledgedHeroIds.contains(hero.id),
    ),
  );

  bool isHeroUnlocked(HeroDefinition hero) => _state.isHeroUnlocked(hero);

  bool canBuyHero(HeroDefinition hero) =>
      _purchaseOutcomeFor(hero) == HeroPurchaseResult.purchased;

  HeroPurchaseResult buyHero(HeroDefinition hero) {
    final outcome = _purchaseOutcomeFor(hero);
    if (outcome != HeroPurchaseResult.purchased) return outcome;
    _commit(_state.withPurchasedHero(hero));
    return outcome;
  }

  void selectHero(HeroDefinition hero) {
    if (!isHeroUnlocked(hero) || selectedHero.id == hero.id) return;
    _commit(_state.copyWith(selectedHeroId: hero.id));
  }

  void acknowledgeHeroes() {
    final heroes = newlyUnlockedHeroes;
    if (heroes.isEmpty) return;
    _commit(_state.withAcknowledgedHeroes(heroes));
  }

  bool owns(EquipmentItem item) => _state.owns(item);

  int levelOf(EquipmentItem item) => _state.levelOf(item);

  bool isEquipped(EquipmentItem item) => _state.isEquipped(item);

  void equip(EquipmentItem item) {
    if (!owns(item) || isEquipped(item)) return;
    _commit(_state.withEquipped(item));
  }

  void unequip(EquipmentSlot slot) {
    if (!_state.equippedIds.containsKey(slot)) return;
    _commit(_state.withoutEquipped(slot));
  }

  UpgradeResult upgrade(EquipmentItem item) {
    if (!owns(item)) return UpgradeResult.notOwned;
    final currentLevel = levelOf(item);
    if (currentLevel >= EquipmentItem.maxLevel) {
      return UpgradeResult.maxLevelReached;
    }
    final cost = item.upgradeCost(currentLevel);
    if (coins < cost) return UpgradeResult.notEnoughCoins;
    _commit(
      _state.spendingCoins(cost).withEquipmentLevel(item, currentLevel + 1),
    );
    return UpgradeResult.upgraded;
  }

  ShopPurchaseResult buy(ItemDefinition item) => switch (item) {
    EquipmentItem() => _buyEquipment(item),
    ConsumableItem() => _buyConsumable(item),
  };

  /// Throws [ChapterLockedException].
  RunConfig prepareRun(int chapterNumber) {
    if (!isChapterUnlocked(chapterNumber)) {
      throw ChapterLockedException(chapterNumber);
    }
    return RunConfig(
      chapter: ChapterCatalog.byNumber(chapterNumber),
      loadout: loadout,
      startingConsumables: consumables,
      hero: selectedHero,
    );
  }

  void applyRunResult(RunResult result) {
    var next = _state
        .earning(
          coins: result.coinsEarned,
          xp: RunExperience.earnedFrom(result),
        )
        .withBestRoom(result.chapterNumber, result.roomsCleared)
        .withConsumables(result.unusedConsumables)
        .copyWith(questBoard: _todayQuestBoard.recordRun(result));
    if (result.isVictory) {
      next = next.withCompletedChapter(
        result.chapterNumber,
        chapterCount: ChapterCatalog.all.length,
      );
    }
    for (final item in result.foundEquipment) {
      next = next.withFoundEquipment(item);
    }
    _commit(next);
  }

  bool claimQuest(String questId) {
    final questBoard = _todayQuestBoard;
    final quest = questBoard.questById(questId);
    if (quest == null || !quest.canClaim) return false;
    _commit(
      _state
          .withReward(quest.reward)
          .copyWith(questBoard: questBoard.markClaimed(questId)),
    );
    return true;
  }

  bool claimDailyBonus() {
    final questBoard = _todayQuestBoard;
    if (!questBoard.canClaimBonus) return false;
    _commit(
      _state
          .withReward(dailyBonusReward)
          .copyWith(questBoard: questBoard.markBonusClaimed()),
    );
    return true;
  }

  EquipmentItem? openChest({ChestType type = ChestType.pokeBall}) {
    if (!canOpen(type)) return null;
    final item = _chestRoller.roll(type);
    final paidState = _state.spendingGems(type.gemCost);
    _commit(
      owns(item)
          ? paidState.withEquipmentLevel(item, _upgradedLevel(item))
          : paidState.withNewEquipment(item),
    );
    return item;
  }

  Future<void> save() => _storage.write(ProfileCodec.encode(_state));

  HeroPurchaseResult _purchaseOutcomeFor(HeroDefinition hero) {
    if (isHeroUnlocked(hero)) return HeroPurchaseResult.alreadyUnlocked;
    if (hero.unlock.kind != HeroUnlockKind.gems) {
      return HeroPurchaseResult.notForSale;
    }
    if (gems < hero.unlock.value) return HeroPurchaseResult.notEnoughGems;
    return HeroPurchaseResult.purchased;
  }

  ShopPurchaseResult _buyEquipment(EquipmentItem item) {
    if (owns(item)) return ShopPurchaseResult.alreadyOwned;
    if (coins < item.price) return ShopPurchaseResult.notEnoughCoins;
    _commit(_state.spendingCoins(item.price).withNewEquipment(item));
    return ShopPurchaseResult.purchased;
  }

  ShopPurchaseResult _buyConsumable(ConsumableItem item) {
    if (coins < item.price) return ShopPurchaseResult.notEnoughCoins;
    _commit(_state.spendingCoins(item.price).withConsumableAdded(item));
    return ShopPurchaseResult.purchased;
  }

  int _upgradedLevel(EquipmentItem item) {
    final nextLevel = levelOf(item) + 1;
    return nextLevel > EquipmentItem.maxLevel
        ? EquipmentItem.maxLevel
        : nextLevel;
  }

  DailyQuestBoard get _todayQuestBoard {
    final today = _clock();
    if (_state.questBoard.isFor(today)) return _state.questBoard;
    _state = _state.copyWith(questBoard: DailyQuestBoard.forDay(today));
    unawaited(save());
    return _state.questBoard;
  }

  void _commit(ProfileState nextState) {
    _state = nextState;
    unawaited(save());
    notifyListeners();
  }
}
