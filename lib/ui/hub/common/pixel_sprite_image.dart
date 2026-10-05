import 'package:flutter/material.dart';

import 'pixel_sprite.dart';
import 'pixel_sprite_painter.dart';

class PixelSpriteImage extends StatelessWidget {
  const PixelSpriteImage({
    required this.sprite,
    this.pixelSize = 3,
    this.tint,
    this.semanticLabel,
    super.key,
  });

  final PixelSprite sprite;
  final double pixelSize;
  final Color? tint;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final image = SizedBox(
      width: sprite.columnCount * pixelSize,
      height: sprite.rowCount * pixelSize,
      child: CustomPaint(
        painter: PixelSpritePainter(sprite: sprite, tint: tint),
      ),
    );
    final label = semanticLabel;
    if (label == null) {
      return ExcludeSemantics(child: image);
    }
    return Semantics(image: true, label: label, child: image);
  }
}
