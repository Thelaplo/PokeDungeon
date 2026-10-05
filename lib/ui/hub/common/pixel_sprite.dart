import 'dart:ui';

class PixelSprite {
  const PixelSprite({required this.rows, required this.palette});

  final List<String> rows;
  final Map<String, Color> palette;

  int get rowCount => rows.length;

  int get columnCount => rows.first.length;
}
