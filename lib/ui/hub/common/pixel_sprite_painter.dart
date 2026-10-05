import 'package:flutter/rendering.dart';

import 'pixel_sprite.dart';

class PixelSpritePainter extends CustomPainter {
  PixelSpritePainter({required this.sprite, this.tint});

  final PixelSprite sprite;
  final Color? tint;

  @override
  void paint(Canvas canvas, Size size) {
    final pixelWidth = size.width / sprite.columnCount;
    final pixelHeight = size.height / sprite.rowCount;
    final paint = Paint()..isAntiAlias = false;
    for (var row = 0; row < sprite.rowCount; row++) {
      final line = sprite.rows[row];
      for (var column = 0; column < line.length; column++) {
        final color = sprite.palette[line[column]];
        if (color == null) {
          continue;
        }
        paint.color = tint ?? color;
        canvas.drawRect(
          Rect.fromLTWH(
            column * pixelWidth,
            row * pixelHeight,
            pixelWidth,
            pixelHeight,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(PixelSpritePainter oldDelegate) =>
      oldDelegate.sprite != sprite || oldDelegate.tint != tint;
}
