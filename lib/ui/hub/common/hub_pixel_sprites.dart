import 'dart:ui';

import 'pixel_sprite.dart';

abstract final class HubPixelSprites {
  static const trainer = PixelSprite(
    rows: [
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
    ],
    palette: {
      'k': Color(0xFF101018),
      'r': Color(0xFFE83838),
      'w': Color(0xFFF8F8F8),
      's': Color(0xFFF8C890),
      'b': Color(0xFF3868E8),
      'd': Color(0xFF283058),
    },
  );
}
