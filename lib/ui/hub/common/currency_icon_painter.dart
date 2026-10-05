import 'package:flutter/material.dart';

import '../hub_style.dart';
import 'hub_currency.dart';

class CurrencyIconPainter extends CustomPainter {
  const CurrencyIconPainter({required this.currency});

  static const _coinRim = Color(0xFFD08A00);
  static const _coinFace = Color(0xFFFFE07A);
  static const _gemDark = Color(0xFF1E8FC8);
  static const _gemLight = Color(0xFFB8F3FF);
  static const _outlineWidthRatio = 0.08;

  final HubCurrency currency;

  @override
  void paint(Canvas canvas, Size size) {
    switch (currency) {
      case HubCurrency.coins:
        _paintCoin(canvas, size);
      case HubCurrency.gems:
        _paintGem(canvas, size);
    }
  }

  void _paintCoin(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final outline = Paint()..color = HubStyle.navy;
    canvas
      ..drawCircle(center, radius, outline)
      ..drawCircle(center, radius * 0.88, Paint()..color = _coinRim)
      ..drawCircle(center, radius * 0.7, Paint()..color = currency.color)
      ..drawCircle(
        center.translate(-radius * 0.22, -radius * 0.22),
        radius * 0.18,
        Paint()..color = _coinFace,
      );
  }

  void _paintGem(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final gemOutline = Path()
      ..moveTo(width * 0.5, 0)
      ..lineTo(width, height * 0.4)
      ..lineTo(width * 0.5, height)
      ..lineTo(0, height * 0.4)
      ..close();
    final topFacet = Path()
      ..moveTo(width * 0.5, height * 0.1)
      ..lineTo(width * 0.85, height * 0.4)
      ..lineTo(width * 0.15, height * 0.4)
      ..close();
    canvas
      ..drawPath(gemOutline, Paint()..color = _gemDark)
      ..drawPath(
        gemOutline,
        Paint()
          ..color = HubStyle.navy
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * _outlineWidthRatio,
      )
      ..drawPath(topFacet, Paint()..color = currency.color)
      ..drawCircle(
        Offset(width * 0.4, height * 0.3),
        size.shortestSide * 0.07,
        Paint()..color = _gemLight,
      );
  }

  @override
  bool shouldRepaint(CurrencyIconPainter oldDelegate) =>
      oldDelegate.currency != currency;
}
