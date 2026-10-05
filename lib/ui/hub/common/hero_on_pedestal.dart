import 'package:flutter/material.dart';

import '../../../models/hero_definition.dart';
import '../hub_style.dart';
import 'hero_portrait.dart';

class HeroOnPedestal extends StatelessWidget {
  const HeroOnPedestal({
    required this.hero,
    required this.size,
    this.isSilhouette = false,
    super.key,
  });

  static const _pedestalWidthRatio = 0.86;
  static const _pedestalHeightRatio = 0.22;
  static const _portraitRatio = 0.9;
  static const _portraitLiftRatio = 0.08;

  final HeroDefinition hero;
  final double size;
  final bool isSilhouette;

  @override
  Widget build(BuildContext context) {
    final pedestalWidth = size * _pedestalWidthRatio;
    final pedestalHeight = size * _pedestalHeightRatio;
    final accent = isSilhouette ? HubStyle.locked : hero.accentColor;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: pedestalWidth,
            height: pedestalHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(accent, Colors.white, 0.25) ?? accent,
                  Color.lerp(accent, Colors.black, 0.45) ?? accent,
                ],
              ),
              borderRadius: BorderRadius.all(
                Radius.elliptical(pedestalWidth / 2, pedestalHeight / 2),
              ),
              border: Border.all(color: HubStyle.navy, width: 2),
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: 0.5), blurRadius: 18),
              ],
            ),
          ),
          Positioned(
            bottom: size * _portraitLiftRatio,
            child: HeroPortrait(
              hero: hero,
              size: size * _portraitRatio,
              isSilhouette: isSilhouette,
            ),
          ),
        ],
      ),
    );
  }
}
