import 'package:flutter/material.dart';

import '../../../game/chapters/chapter_catalog.dart';
import '../../../game/heroes/hero_catalog.dart';
import '../../../game/wave_plan.dart';
import '../../../models/chapter.dart';
import '../../../models/monster_data.dart';
import '../../../profile/player_profile.dart';
import '../../../services/poke_api_service.dart';
import '../common/hub_button.dart';
import '../common/hub_layout.dart';
import '../common/type_matchups.dart';
import '../hub_style.dart';
import 'chapter_card.dart';
import 'chapter_page_controls.dart';
import 'chapter_run_launcher.dart';
import 'daily_event_card.dart';

class AdventureTabView extends StatefulWidget {
  const AdventureTabView({required this.profile, required this.api, super.key});

  final PlayerProfile profile;
  final PokeApiService api;

  @override
  State<AdventureTabView> createState() => _AdventureTabViewState();
}

class _AdventureTabViewState extends State<AdventureTabView> {
  static const _pageSwitchDuration = Duration(milliseconds: 280);
  static const _viewportFraction = 0.88;
  static const _playIconColor = HubStyle.white;

  final DateTime _today = DateTime.now();
  final Map<int, Future<MonsterData>> _monsterFutures = {};
  late int _selectedIndex = _initialIndex();
  late final PageController _pageController = PageController(
    initialPage: _selectedIndex,
    viewportFraction: _viewportFraction,
  );
  bool _isLaunchingRun = false;

  List<Chapter> get _chapters => ChapterCatalog.all;

  int _initialIndex() => (widget.profile.highestUnlockedChapter - 1).clamp(
    0,
    _chapters.length - 1,
  );

  bool _isLocked(Chapter chapter) =>
      chapter.number > widget.profile.highestUnlockedChapter;

  Future<MonsterData> _monster(int pokemonId) => _monsterFutures.putIfAbsent(
    pokemonId,
    () => widget.api.fetchMonster(pokemonId),
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: _pageSwitchDuration,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _launchRun(Chapter chapter) async {
    if (_isLaunchingRun) {
      return;
    }
    setState(() => _isLaunchingRun = true);
    await ChapterRunLauncher(
      profile: widget.profile,
      api: widget.api,
    ).launch(context, chapter);
    if (!mounted) {
      return;
    }
    setState(() => _isLaunchingRun = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.profile,
      builder: (context, _) {
        final selectedChapter = _chapters[_selectedIndex];
        final isSelectedLocked = _isLocked(selectedChapter);
        final canGoBack = _selectedIndex > 0;
        final canGoForward = _selectedIndex < _chapters.length - 1;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            HubLayout.pagePadding,
            4,
            HubLayout.pagePadding,
            HubLayout.pagePadding,
          ),
          child: Column(
            children: [
              DailyEventCard(
                legendary: _monster(WavePlan.dailyLegendaryId(_today)),
                eventRoom: WavePlan.dailyEventWaveFor(_today),
              ),
              const SizedBox(height: HubLayout.cardSpacing),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _chapters.length,
                  onPageChanged: (index) =>
                      setState(() => _selectedIndex = index),
                  itemBuilder: (context, index) {
                    final chapter = _chapters[index];
                    final chapterTypes = TypeMatchups.chapterTypes(chapter);
                    return ChapterCard(
                      recommendedHeroes: TypeMatchups.recommendedHeroes(
                        chapterTypes: chapterTypes,
                        heroes: HeroCatalog.all,
                        isUnlocked: widget.profile.isHeroUnlocked,
                      ),
                      isHeroUnlocked: widget.profile.isHeroUnlocked,
                      isSelectedHeroVulnerable: TypeMatchups.isVulnerable(
                        widget.profile.selectedHero,
                        chapterTypes,
                      ),
                      chapter: chapter,
                      finalBoss: _monster(chapter.finalBossId),
                      bestRoom: widget.profile.bestRoomFor(chapter.number),
                      isCompleted: widget.profile.isChapterCompleted(
                        chapter.number,
                      ),
                      isLocked: _isLocked(chapter),
                    );
                  },
                ),
              ),
              ChapterPageControls(
                pageCount: _chapters.length,
                selectedIndex: _selectedIndex,
                onPrevious: canGoBack
                    ? () => _goToPage(_selectedIndex - 1)
                    : null,
                onNext: canGoForward
                    ? () => _goToPage(_selectedIndex + 1)
                    : null,
              ),
              const SizedBox(height: HubLayout.cardSpacing),
              SizedBox(
                width: double.infinity,
                child: HubButton(
                  label: isSelectedLocked ? 'VERROUILLÉ' : 'JOUER',
                  semanticLabel: isSelectedLocked
                      ? 'Chapitre ${selectedChapter.number} verrouillé'
                      : 'Jouer le chapitre ${selectedChapter.number}',
                  leading: Icon(
                    isSelectedLocked
                        ? Icons.lock_rounded
                        : Icons.play_arrow_rounded,
                    size: 30,
                    color: isSelectedLocked
                        ? const Color(0xFFE1E5F0)
                        : _playIconColor,
                  ),
                  onPressed: isSelectedLocked || _isLaunchingRun
                      ? null
                      : () => _launchRun(selectedChapter),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
