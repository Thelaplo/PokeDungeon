import 'dart:ui';

import 'package:flame/components.dart';

import '../../models/room_theme.dart';

class DungeonRoom extends PositionComponent {
  DungeonRoom({required double roomSize})
    : super(size: Vector2.all(roomSize), priority: -1);

  static const wallThickness = 40.0;
  static const _tileSize = 48.0;
  static const _torchSize = 12.0;
  static const _torchSpacing = 220.0;

  RoomTheme _theme = RoomTheme.crypt;
  final Paint _floorPaint = Paint();
  final Paint _floorAltPaint = Paint();
  final Paint _wallPaint = Paint();
  final Paint _accentPaint = Paint();

  RoomTheme get theme => _theme;

  set theme(RoomTheme newTheme) {
    _theme = newTheme;
    _applyPaints();
  }

  Rect get playableArea => Rect.fromLTWH(
    wallThickness,
    wallThickness,
    size.x - wallThickness * 2,
    size.y - wallThickness * 2,
  );

  @override
  Future<void> onLoad() async {
    _applyPaints();
  }

  void _applyPaints() {
    _floorPaint.color = _theme.floorColor;
    _floorAltPaint.color = _theme.floorAltColor;
    _wallPaint.color = _theme.wallColor;
    _accentPaint.color = _theme.accentColor;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _wallPaint);
    _renderFloor(canvas);
    _renderTorches(canvas);
  }

  void _renderFloor(Canvas canvas) {
    final area = playableArea;
    canvas.drawRect(area, _floorPaint);
    var row = 0;
    for (var y = area.top; y < area.bottom; y += _tileSize, row++) {
      var column = 0;
      for (var x = area.left; x < area.right; x += _tileSize, column++) {
        if ((row + column).isEven) {
          continue;
        }
        final tile = Rect.fromLTRB(
          x,
          y,
          (x + _tileSize).clamp(area.left, area.right),
          (y + _tileSize).clamp(area.top, area.bottom),
        );
        canvas.drawRect(tile, _floorAltPaint);
      }
    }
  }

  void _renderTorches(Canvas canvas) {
    const inset = (wallThickness - _torchSize) / 2;
    for (
      var offset = _torchSpacing / 2;
      offset < size.x;
      offset += _torchSpacing
    ) {
      canvas
        ..drawRect(
          Rect.fromLTWH(offset, inset, _torchSize, _torchSize),
          _accentPaint,
        )
        ..drawRect(
          Rect.fromLTWH(
            offset,
            size.y - inset - _torchSize,
            _torchSize,
            _torchSize,
          ),
          _accentPaint,
        )
        ..drawRect(
          Rect.fromLTWH(inset, offset, _torchSize, _torchSize),
          _accentPaint,
        )
        ..drawRect(
          Rect.fromLTWH(
            size.x - inset - _torchSize,
            offset,
            _torchSize,
            _torchSize,
          ),
          _accentPaint,
        );
    }
  }
}
