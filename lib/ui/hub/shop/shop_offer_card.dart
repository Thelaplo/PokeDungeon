import 'package:flutter/material.dart';

import '../../../models/item_definition.dart';
import '../common/currency_icon.dart';
import '../common/hub_button.dart';
import '../common/hub_button_variant.dart';
import '../common/hub_currency.dart';
import '../common/hub_panel.dart';
import '../common/rarity_item_frame.dart';
import '../hub_style.dart';

class ShopOfferCard extends StatelessWidget {
  const ShopOfferCard({
    required this.item,
    required this.caption,
    required this.isOwned,
    required this.canAfford,
    required this.onBuy,
    super.key,
  });

  static const _frameSide = 64.0;
  static const _effectsHeight = 34.0;

  final ItemDefinition item;
  final String caption;
  final bool isOwned;
  final bool canAfford;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return HubPanel(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      radius: 18,
      child: Column(
        children: [
          RarityItemFrame(item: item, side: _frameSide),
          const SizedBox(height: 8),
          Text(
            item.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HubStyle.title(
              fontSize: 15,
              color: HubStyle.rarityColor(item.rarity),
            ),
          ),
          Text(
            caption,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: HubStyle.body(fontSize: 11, color: HubStyle.mutedText),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: _effectsHeight,
            child: Text(
              item.describe().join(' · '),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: HubStyle.body(fontSize: 11),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: isOwned
                ? const HubButton(
                    label: 'POSSÉDÉ',
                    isCompact: true,
                    onPressed: null,
                  )
                : HubButton(
                    label: '${item.price}',
                    isCompact: true,
                    variant: HubButtonVariant.secondary,
                    semanticLabel:
                        'Acheter ${item.name} pour ${item.price} Pokédollars',
                    leading: const CurrencyIcon(
                      currency: HubCurrency.coins,
                      size: 18,
                    ),
                    onPressed: canAfford ? onBuy : null,
                  ),
          ),
        ],
      ),
    );
  }
}
