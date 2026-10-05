import 'dart:ui';

abstract final class TrainerPixelArt {
  static const pixelSize = 3.0;
  static const _rows = [
    '....kkkk....',
    '...krrrrk...',
    '..krrwrrrk..',
    '..kkkkkkkkk.',
    '..kssssssk..',
    '..kskssksk..',
    '..kssssssk..',
    '...kbbbbk...',
    '..kbbwwbbk..',
    '.ksbbbbbbsk.',
    '..kbbbbbbk..',
    '..kddkkddk..',
    '..kdk..kdk..',
    '..kk....kk..',
  ];
  static final _palette = {
    'k': Paint()..color = const Color(0xFF101018),
    'r': Paint()..color = const Color(0xFFE83838),
    'w': Paint()..color = const Color(0xFFF8F8F8),
    's': Paint()..color = const Color(0xFFF8C890),
    'b': Paint()..color = const Color(0xFF3868E8),
    'd': Paint()..color = const Color(0xFF283058),
  };

  static double get width => _rows.first.length * pixelSize;

  static double get height => _rows.length * pixelSize;

  static void render(Canvas canvas, {required bool isFacingLeft}) {
    canvas.save();
    if (isFacingLeft) {
      canvas
        ..translate(width, 0)
        ..scale(-1, 1);
    }
    for (var row = 0; row < _rows.length; row++) {
      final line = _rows[row];
      for (var column = 0; column < line.length; column++) {
        final paint = _palette[line[column]];
        if (paint == null) {
          continue;
        }
        canvas.drawRect(
          Rect.fromLTWH(
            column * pixelSize,
            row * pixelSize,
            pixelSize,
            pixelSize,
          ),
          paint,
        );
      }
    }
    canvas.restore();
  }
}
