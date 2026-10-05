import 'package:flutter/material.dart';

import '../../hub/common/currency_icon.dart';
import '../../hub/common/hub_currency.dart';
import '../../hub/hub_style.dart';

class CoinsPill extends StatelessWidget {
  const CoinsPill({required this.coins, super.key});

  final ValueNotifier<int> coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 12, 4),
      decoration: BoxDecoration(
        color: HubStyle.navigationBar,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HubStyle.panelBorder, width: 2),
        boxShadow: const [
          BoxShadow(color: HubStyle.navy, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CurrencyIcon(currency: HubCurrency.coins, size: 22),
          const SizedBox(width: 6),
          ValueListenableBuilder<int>(
            valueListenable: coins,
            builder: (context, value, _) => Text(
              '$value',
              style: HubStyle.title(fontSize: 16, color: HubStyle.gold),
            ),
          ),
        ],
      ),
    );
  }
}
