import 'package:flutter/material.dart';

import '../../../models/item_definition.dart';
import '../../../models/player_stats.dart';
import '../../../profile/player_profile.dart';
import '../common/hub_button.dart';
import '../common/hub_button_variant.dart';
import '../common/hub_layout.dart';
import '../common/section_title.dart';
import '../heroes/heroes_screen.dart';
import '../hub_style.dart';
import 'equipment_detail_sheet.dart';
import 'equipment_hero_center.dart';
import 'equipped_slot_card.dart';
import 'loadout_stats_panel.dart';
import 'owned_equipment_grid.dart';

class EquipmentTabView extends StatelessWidget {
  const EquipmentTabView({required this.profile, super.key});

  static const _slotColumnWidth = 100.0;
  static const _slotSpacing = 10.0;

  final PlayerProfile profile;

  void _openDetail(BuildContext context, EquipmentItem item) {
    EquipmentDetailSheet.show(context, profile: profile, item: item);
  }

  void _openHeroes(BuildContext context) {
    Navigator.of(context).push(HeroesScreen.route(profile: profile));
  }

  Widget _slotCard(BuildContext context, EquipmentSlot slot) {
    final owned = profile.equipped[slot];
    return EquippedSlotCard(
      slot: slot,
      equipped: owned,
      onTap: () {
        if (owned == null) {
          return;
        }
        _openDetail(context, owned.item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: profile,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(HubLayout.pagePadding),
        children: [
          const SectionTitle(
            title: 'Équipement',
            subtitle: 'Touche un objet pour l\'équiper ou l\'améliorer',
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _slotColumnWidth,
                child: Column(
                  children: [
                    _slotCard(context, EquipmentSlot.attack),
                    const SizedBox(height: _slotSpacing),
                    _slotCard(context, EquipmentSlot.defense),
                  ],
                ),
              ),
              Expanded(
                child: EquipmentHeroCenter(
                  hero: profile.selectedHero,
                  onTap: () => _openHeroes(context),
                ),
              ),
              SizedBox(
                width: _slotColumnWidth,
                child: Column(
                  children: [
                    _slotCard(context, EquipmentSlot.accessory),
                    const SizedBox(height: _slotSpacing + 6),
                    HubButton(
                      label: 'HÉROS',
                      isCompact: true,
                      variant: HubButtonVariant.info,
                      semanticLabel: 'Ouvrir la sélection des héros',
                      leading: const Icon(
                        Icons.groups_rounded,
                        size: 18,
                        color: HubStyle.white,
                      ),
                      onPressed: () => _openHeroes(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: HubLayout.cardSpacing + 4),
          LoadoutStatsPanel(
            stats: PlayerStats.from([
              ...profile.loadout.modifiers,
              profile.selectedHero.modifiers,
            ]),
          ),
          const SectionTitle(title: 'Sac à dos'),
          OwnedEquipmentGrid(
            ownedEquipment: profile.ownedEquipment,
            isEquipped: profile.isEquipped,
            onSelected: (item) => _openDetail(context, item),
          ),
        ],
      ),
    );
  }
}
