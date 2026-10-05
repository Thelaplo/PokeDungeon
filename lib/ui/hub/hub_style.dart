import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/item_definition.dart';

abstract final class HubStyle {
  static const navy = Color(0xFF08181E);
  static const deepNavy = Color(0xFF08181E);
  static const backgroundTop = Color(0xFF1F4A57);
  static const backgroundMiddle = Color(0xFF163844);
  static const backgroundBottom = Color(0xFF0D2129);
  static const panelTop = Color(0xFF1E4E5C);
  static const panelBottom = Color(0xFF153A45);
  static const panelBorder = Color(0xFF3FA7A0);
  static const navigationBar = Color(0xFF0C2229);
  static const navigationShadow = Color(0xFF061418);
  static const activeTabTop = Color(0xFF2C7A7B);
  static const activeTabBottom = Color(0xFF1B5556);
  static const white = Color(0xFFFFFFFF);
  static const softText = Color(0xFFD7F0EE);
  static const mutedText = Color(0xFF9FD3CF);
  static const accent = Color(0xFFFF8A70);
  static const gold = Color(0xFFFFC93C);
  static const gem = Color(0xFF5CE1FF);
  static const success = Color(0xFF5EE6B0);
  static const danger = Color(0xFFFF5A5A);
  static const eventBorder = Color(0xFFC77DFF);
  static const locked = Color(0xFF5F7378);
  static const silhouette = Color(0xFF06141A);
  static const scrim = Color(0x9908181E);

  static const panelRadius = 20.0;
  static const tileRadius = 14.0;
  static const panelShadowOffset = Offset(0, 6);

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, backgroundMiddle, backgroundBottom],
  );

  static const panelGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [panelTop, panelBottom],
  );

  static const activeTabGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [activeTabTop, activeTabBottom],
  );

  static const progressGradient = LinearGradient(
    colors: [Color(0xFFFFB09E), accent, Color(0xFFF2554A)],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF8A75), Color(0xFFF2554A)],
  );

  static const successGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5EE6B0), Color(0xFF22B783)],
  );

  static const eventGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6A2FB8), Color(0xFF3B1E7A)],
  );

  static TextStyle title({
    double fontSize = 20,
    Color color = white,
    Color outlineColor = navy,
  }) => GoogleFonts.lilitaOne(
    fontSize: fontSize,
    color: color,
    height: 1.15,
    shadows: [
      Shadow(offset: const Offset(0, 2), color: outlineColor),
      Shadow(offset: const Offset(1, 1), color: outlineColor),
      Shadow(offset: const Offset(-1, 1), color: outlineColor),
      Shadow(offset: const Offset(1, -1), color: outlineColor),
      Shadow(offset: const Offset(-1, -1), color: outlineColor),
    ],
  );

  static TextStyle plainTitle({double fontSize = 20, Color color = white}) =>
      GoogleFonts.lilitaOne(fontSize: fontSize, color: color, height: 1.15);

  static TextStyle body({double fontSize = 13, Color color = softText}) =>
      GoogleFonts.nunito(
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.w800,
        height: 1.3,
      );

  static BoxDecoration panelDecoration({
    Color borderColor = panelBorder,
    double radius = panelRadius,
    Gradient gradient = panelGradient,
  }) => BoxDecoration(
    gradient: gradient,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor, width: 2),
    boxShadow: const [BoxShadow(color: navy, offset: panelShadowOffset)],
  );

  static LinearGradient rarityGradient(ItemRarity rarity) {
    final colors = switch (rarity) {
      ItemRarity.common => const [Color(0xFFB9C2D0), Color(0xFF7E8899)],
      ItemRarity.rare => const [Color(0xFF5AB0FF), Color(0xFF2F6FE0)],
      ItemRarity.epic => const [Color(0xFFC77DFF), Color(0xFF7B3FD6)],
      ItemRarity.legendary => const [Color(0xFFFFD54A), Color(0xFFF29B00)],
    };
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
    );
  }

  static Color rarityColor(ItemRarity rarity) =>
      rarityGradient(rarity).colors.first;
}
