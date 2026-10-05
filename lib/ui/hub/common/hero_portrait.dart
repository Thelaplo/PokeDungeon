import 'package:flutter/material.dart';

import '../../../models/hero_definition.dart';
import '../hub_style.dart';
import 'hub_pixel_sprites.dart';
import 'pixel_sprite_image.dart';

class HeroPortrait extends StatelessWidget {
  const HeroPortrait({
    required this.hero,
    required this.size,
    this.isSilhouette = false,
    super.key,
  });

  static const _trainerHeightRatio = 0.8;
  static const _fallbackIconRatio = 0.5;

  final HeroDefinition hero;
  final double size;
  final bool isSilhouette;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: isSilhouette ? 'Héros verrouillé' : hero.name,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: Center(child: _buildSprite()),
      ),
    );
  }

  Widget _buildSprite() {
    final spriteUrl = hero.spriteUrl;
    if (spriteUrl == null) {
      return PixelSpriteImage(
        sprite: HubPixelSprites.trainer,
        pixelSize:
            size * _trainerHeightRatio / HubPixelSprites.trainer.rowCount,
        tint: isSilhouette ? HubStyle.silhouette : null,
      );
    }
    final image = Image.network(
      spriteUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.catching_pokemon,
        size: size * _fallbackIconRatio,
        color: HubStyle.white,
      ),
    );
    if (!isSilhouette) {
      return image;
    }
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(HubStyle.silhouette, BlendMode.srcIn),
      child: image,
    );
  }
}
