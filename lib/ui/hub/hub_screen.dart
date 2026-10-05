import 'package:flutter/material.dart';

import '../../profile/player_profile.dart';
import '../../services/poke_api_service.dart';
import 'adventure/adventure_tab_view.dart';
import 'common/hub_background.dart';
import 'common/hub_content_frame.dart';
import 'equipment/equipment_tab_view.dart';
import 'header/profile_header_view.dart';
import 'heroes/new_hero_dialog.dart';
import 'navigation/hub_navigation_bar.dart';
import 'navigation/hub_tab.dart';
import 'quests/quests_tab_view.dart';
import 'shop/shop_tab_view.dart';

class HubScreen extends StatefulWidget {
  const HubScreen({required this.profile, required this.api, super.key});

  final PlayerProfile profile;
  final PokeApiService api;

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  HubTab _selectedTab = HubTab.adventure;
  bool _isAnnouncingHeroes = false;

  @override
  void initState() {
    super.initState();
    widget.profile.addListener(_scheduleHeroAnnouncement);
    _scheduleHeroAnnouncement();
  }

  @override
  void dispose() {
    widget.profile.removeListener(_scheduleHeroAnnouncement);
    super.dispose();
  }

  void _scheduleHeroAnnouncement() {
    if (_isAnnouncingHeroes || widget.profile.newlyUnlockedHeroes.isEmpty) {
      return;
    }
    _isAnnouncingHeroes = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _announceHeroes());
  }

  Future<void> _announceHeroes() async {
    if (!mounted) {
      return;
    }
    final heroes = List.of(widget.profile.newlyUnlockedHeroes);
    await showDialog<void>(
      context: context,
      builder: (context) => NewHeroDialog(heroes: heroes),
    );
    widget.profile.acknowledgeHeroes();
    _isAnnouncingHeroes = false;
  }

  void _selectTab(HubTab tab) {
    if (tab == _selectedTab) {
      return;
    }
    setState(() => _selectedTab = tab);
  }

  Widget _buildTabView(HubTab tab) => switch (tab) {
    HubTab.shop => ShopTabView(profile: widget.profile),
    HubTab.equipment => EquipmentTabView(profile: widget.profile),
    HubTab.adventure => AdventureTabView(
      profile: widget.profile,
      api: widget.api,
    ),
    HubTab.quests => QuestsTabView(profile: widget.profile),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HubBackground(
        child: SafeArea(
          bottom: false,
          child: HubContentFrame(
            child: Column(
              children: [
                ProfileHeaderView(
                  profile: widget.profile,
                  onShopRequested: () => _selectTab(HubTab.shop),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab.index,
                    children: [
                      for (final tab in HubTab.values) _buildTabView(tab),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: widget.profile,
        builder: (context, _) => HubNavigationBar(
          selectedTab: _selectedTab,
          hasClaimableQuest: widget.profile.dailyQuests.any(
            (quest) => quest.canClaim,
          ),
          onTabSelected: _selectTab,
        ),
      ),
    );
  }
}
