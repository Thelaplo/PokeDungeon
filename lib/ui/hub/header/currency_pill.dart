import 'package:flutter/material.dart';

import '../common/currency_icon.dart';
import '../common/hub_currency.dart';
import '../common/hub_layout.dart';
import '../hub_style.dart';

class CurrencyPill extends StatelessWidget {
  const CurrencyPill({
    required this.currency,
    required this.amount,
    required this.onAddPressed,
    super.key,
  });

  static const _minWidth = 112.0;
  static const _iconSize = 26.0;
  static const _addBubbleSide = 20.0;
  static const _capsuleAlpha = 0.7;

  final HubCurrency currency;
  final int amount;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$amount ${currency.name}, ouvrir la boutique',
      excludeSemantics: true,
      child: InkWell(
        onTap: onAddPressed,
        borderRadius: BorderRadius.circular(HubLayout.minTouchTarget),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: HubLayout.minTouchTarget,
            minWidth: _minWidth,
          ),
          child: Center(
            widthFactor: 1,
            child: Container(
              padding: const EdgeInsets.fromLTRB(2, 2, 3, 2),
              decoration: BoxDecoration(
                color: HubStyle.deepNavy.withValues(alpha: _capsuleAlpha),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CurrencyIcon(currency: currency, size: _iconSize),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 48),
                    child: Text(
                      '$amount',
                      textAlign: TextAlign.right,
                      style: HubStyle.title(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const _AddBubble(side: _addBubbleSide),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddBubble extends StatelessWidget {
  const _AddBubble({required this.side});

  final double side;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        gradient: HubStyle.successGradient,
        shape: BoxShape.circle,
        border: Border.all(color: HubStyle.navy, width: 1.5),
      ),
      child: const Icon(Icons.add_rounded, size: 15, color: HubStyle.white),
    );
  }
}
