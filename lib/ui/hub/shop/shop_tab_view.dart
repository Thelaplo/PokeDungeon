import 'package:flutter/material.dart';

import '../../../game/items/item_catalog.dart';
import '../../../models/item_definition.dart';
import '../../../profile/player_profile.dart';
import '../common/hub_layout.dart';
import '../common/hub_snack_bar.dart';
import '../common/responsive_card_grid.dart';
import '../common/section_title.dart';
import 'chest_card.dart';
import 'chest_reveal_dialog.dart';
import 'shop_offer_card.dart';
import 'shop_purchase_message.dart';

class ShopTabView extends StatelessWidget {
  const ShopTabView({required this.profile, super.key});

  final PlayerProfile profile;

  int _stockOf(ConsumableItem consumable) {
    for (final entry in profile.consumables.entries) {
      if (entry.key.id == consumable.id) {
        return entry.value;
      }
    }
    return 0;
  }

  void _openChest(BuildContext context, ChestType type) {
    final item = profile.openChest(type: type);
    if (item == null) {
      showHubSnackBar(context, 'Pas assez de gemmes.');
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) =>
          ChestRevealDialog(item: item, chestLabel: type.label),
    );
  }

  void _buy(BuildContext context, ItemDefinition item) {
    showHubSnackBar(context, shopPurchaseMessage(profile.buy(item), item));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: profile,
      builder: (context, _) {
        final equipmentForSale = ItemCatalog.equipment.where(
          (item) => item.isForSale,
        );
        final consumablesForSale = ItemCatalog.consumables.where(
          (item) => item.isForSale,
        );
        return ListView(
          padding: const EdgeInsets.all(HubLayout.pagePadding),
          children: [
            const SectionTitle(
              title: 'Coffres',
              subtitle: 'Un équipement aléatoire à chaque ouverture',
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final type in ChestType.values) ...[
                  if (type != ChestType.values.first) const SizedBox(width: 12),
                  Expanded(
                    child: ChestCard(
                      type: type,
                      canOpen: profile.canOpen(type),
                      onOpen: () => _openChest(context, type),
                    ),
                  ),
                ],
              ],
            ),
            const SectionTitle(title: 'Équipement'),
            ResponsiveCardGrid(
              children: [
                for (final item in equipmentForSale)
                  ShopOfferCard(
                    item: item,
                    caption: '${item.slot.label} · ${item.rarity.label}',
                    isOwned: profile.owns(item),
                    canAfford: profile.coins >= item.price,
                    onBuy: () => _buy(context, item),
                  ),
              ],
            ),
            const SectionTitle(
              title: 'Objets de soutien',
              subtitle: 'Emportés lors de ta prochaine aventure',
            ),
            ResponsiveCardGrid(
              children: [
                for (final consumable in consumablesForSale)
                  ShopOfferCard(
                    item: consumable,
                    caption: 'En stock : ${_stockOf(consumable)}',
                    isOwned: false,
                    canAfford: profile.coins >= consumable.price,
                    onBuy: () => _buy(context, consumable),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
