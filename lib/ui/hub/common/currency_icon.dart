import 'package:flutter/material.dart';

import 'currency_icon_painter.dart';
import 'hub_currency.dart';

class CurrencyIcon extends StatelessWidget {
  const CurrencyIcon({required this.currency, this.size = 20, super.key});

  final HubCurrency currency;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: CurrencyIconPainter(currency: currency)),
      ),
    );
  }
}
