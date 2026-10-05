import 'package:flutter/material.dart';

import '../../../game/heroes/hero_catalog.dart';
import '../../../models/hero_definition.dart';
import '../../../profile/player_profile.dart';
import '../common/currency_icon.dart';
import '../common/hub_background.dart';
import '../common/hub_button.dart';
import '../common/hub_content_frame.dart';
import '../common/hub_currency.dart';
import '../common/hub_icon_button.dart';
import '../common/hub_layout.dart';
import '../common/hub_snack_bar.dart';
import '../hub_style.dart';
import 'hero_purchase_message.dart';
import 'hero_roster_card.dart';
import 'hero_showcase.dart';

class HeroesScreen extends StatefulWidget {
  const HeroesScreen({required this.profile, super.key});

  final PlayerProfile profile;

  static Route<void> route({required PlayerProfile profile}) =>
      MaterialPageRoute<void>(
        builder: (context) => HeroesScreen(profile: profile),
      );

  @override
  State<HeroesScreen> createState() => _HeroesScreenState();
}

class _HeroesScreenState extends State<HeroesScreen> {
  static const _rosterHeight = 196.0;

  late HeroDefinition _previewedHero = widget.profile.selectedHero;

  PlayerProfile get _profile => widget.profile;

  bool _isSelected(HeroDefinition hero) => _profile.selectedHero.id == hero.id;

  void _preview(HeroDefinition hero) {
    setState(() => _previewedHero = hero);
  }

  void _chooseHero() {
    _profile.selectHero(_previewedHero);
    showHubSnackBar(context, '${_previewedHero.name} part à l\'aventure !');
  }

  void _buyHero(HeroDefinition hero) {
    final result = _profile.buyHero(hero);
    if (result == HeroPurchaseResult.purchased) {
      setState(() => _previewedHero = hero);
    }
    showHubSnackBar(context, heroPurchaseMessage(result, hero));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HubBackground(
        child: SafeArea(
          child: HubContentFrame(
            child: ListenableBuilder(
              listenable: _profile,
              builder: (context, _) {
                final isUnlocked = _profile.isHeroUnlocked(_previewedHero);
                final isSelected = _isSelected(_previewedHero);
                return Column(
                  children: [
                    _HeroesTopBar(gems: _profile.gems),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: HubLayout.pagePadding,
                        ),
                        child: HeroShowcase(
                          hero: _previewedHero,
                          isUnlocked: isUnlocked,
                          isSelected: isSelected,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: _rosterHeight,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(
                          HubLayout.pagePadding,
                          14,
                          HubLayout.pagePadding,
                          10,
                        ),
                        itemCount: HeroCatalog.all.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final hero = HeroCatalog.all[index];
                          return HeroRosterCard(
                            hero: hero,
                            isUnlocked: _profile.isHeroUnlocked(hero),
                            isSelected: _isSelected(hero),
                            isPreviewed: hero.id == _previewedHero.id,
                            canBuy: _profile.canBuyHero(hero),
                            onTap: () => _preview(hero),
                            onBuy: () => _buyHero(hero),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        HubLayout.pagePadding,
                        0,
                        HubLayout.pagePadding,
                        HubLayout.pagePadding,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: HubButton(
                          label: isSelected ? 'CHOISI' : 'CHOISIR',
                          semanticLabel: isSelected
                              ? '${_previewedHero.name} est déjà choisi'
                              : 'Choisir ${_previewedHero.name}',
                          onPressed: isUnlocked && !isSelected
                              ? _chooseHero
                              : null,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroesTopBar extends StatelessWidget {
  const _HeroesTopBar({required this.gems});

  final int gems;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
      child: Row(
        children: [
          HubIconButton(
            icon: Icons.arrow_back_rounded,
            semanticLabel: 'Retour',
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              header: true,
              child: Text('Héros', style: HubStyle.title(fontSize: 28)),
            ),
          ),
          Semantics(
            label: '$gems gemmes',
            excludeSemantics: true,
            child: Container(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
              decoration: BoxDecoration(
                color: HubStyle.deepNavy.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CurrencyIcon(currency: HubCurrency.gems, size: 24),
                  const SizedBox(width: 6),
                  Text('$gems', style: HubStyle.title(fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
