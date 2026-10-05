import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'chapter_scenery.dart';

class ChapterSceneryPainter extends CustomPainter {
  const ChapterSceneryPainter({
    required this.scenery,
    required this.accentColor,
  });

  static const _daySkyTop = Color(0xFF5DB8FF);
  static const _daySkyBottom = Color(0xFFCDEBFF);
  static const _nightSkyTop = Color(0xFF151A45);
  static const _nightSkyBottom = Color(0xFF4A3A8A);
  static const _sunColor = Color(0xFFFFF4C2);
  static const _moonColor = Color(0xFFF2F0DC);
  static const _snowColor = Color(0xFFF7FBFF);
  static const _lavaRock = Color(0xFF4A2418);
  static const _smokeColor = Color(0x99D8D2CC);
  static const _windowColor = Color(0xFFFFE680);
  static const _skyAccentBlend = 0.25;
  static const _waveCount = 3;

  final ChapterScenery scenery;
  final Color accentColor;

  Color _shade(Color color, double amount) =>
      Color.lerp(color, Colors.black, amount) ?? color;

  Color _tint(Color color, double amount) =>
      Color.lerp(color, Colors.white, amount) ?? color;

  Paint _fill(Color color) => Paint()..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    _paintSky(canvas, size);
    switch (scenery) {
      case ChapterScenery.hills:
        _paintHills(canvas, size);
      case ChapterScenery.mountains:
        _paintMountains(canvas, size);
      case ChapterScenery.volcano:
        _paintVolcano(canvas, size);
      case ChapterScenery.waves:
        _paintWaves(canvas, size);
      case ChapterScenery.city:
        _paintCity(canvas, size);
      case ChapterScenery.tower:
        _paintTower(canvas, size);
    }
    _paintGround(canvas, size);
  }

  void _paintSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final topColor = scenery.isNight ? _nightSkyTop : _daySkyTop;
    final bottomColor = scenery.isNight ? _nightSkyBottom : _daySkyBottom;
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(topColor, accentColor, _skyAccentBlend) ?? topColor,
          Color.lerp(bottomColor, accentColor, _skyAccentBlend) ?? bottomColor,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);
  }

  Path _polygon(Size size, List<Offset> fractions) {
    final path = Path()..moveTo(0, size.height);
    for (final fraction in fractions) {
      path.lineTo(fraction.dx * size.width, fraction.dy * size.height);
    }
    return path
      ..lineTo(size.width, size.height)
      ..close();
  }

  void _paintHills(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    canvas.drawCircle(
      Offset(width * 0.8, height * 0.22),
      width * 0.08,
      _fill(_sunColor),
    );
    final backHills = Path()
      ..moveTo(0, height * 0.62)
      ..quadraticBezierTo(width * 0.25, height * 0.4, width * 0.5, height * 0.6)
      ..quadraticBezierTo(width * 0.75, height * 0.42, width, height * 0.58)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    final frontHills = Path()
      ..moveTo(0, height * 0.72)
      ..quadraticBezierTo(width * 0.3, height * 0.54, width * 0.6, height * 0.7)
      ..quadraticBezierTo(width * 0.85, height * 0.6, width, height * 0.68)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas
      ..drawPath(backHills, _fill(_tint(accentColor, 0.35)))
      ..drawPath(frontHills, _fill(accentColor));
    for (final treeX in const [0.12, 0.2, 0.68, 0.9]) {
      canvas.drawCircle(
        Offset(width * treeX, height * 0.62),
        width * 0.035,
        _fill(_shade(accentColor, 0.3)),
      );
    }
  }

  void _paintMountains(Canvas canvas, Size size) {
    const backPeaks = [
      Offset(0, 0.6),
      Offset(0.15, 0.36),
      Offset(0.3, 0.55),
      Offset(0.5, 0.26),
      Offset(0.7, 0.5),
      Offset(0.85, 0.34),
      Offset(1, 0.55),
    ];
    const frontPeaks = [
      Offset(0, 0.76),
      Offset(0.2, 0.56),
      Offset(0.4, 0.72),
      Offset(0.65, 0.5),
      Offset(0.9, 0.7),
      Offset(1, 0.66),
    ];
    canvas.drawPath(_polygon(size, backPeaks), _fill(_tint(accentColor, 0.3)));
    for (final peak in const [Offset(0.5, 0.26), Offset(0.15, 0.36)]) {
      final snowCap = Path()
        ..moveTo(peak.dx * size.width, peak.dy * size.height)
        ..lineTo((peak.dx + 0.05) * size.width, (peak.dy + 0.08) * size.height)
        ..lineTo((peak.dx - 0.05) * size.width, (peak.dy + 0.08) * size.height)
        ..close();
      canvas.drawPath(snowCap, _fill(_snowColor));
    }
    canvas.drawPath(_polygon(size, frontPeaks), _fill(accentColor));
  }

  void _paintVolcano(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final cone = Path()
      ..moveTo(width * 0.16, height)
      ..lineTo(width * 0.42, height * 0.34)
      ..lineTo(width * 0.58, height * 0.34)
      ..lineTo(width * 0.84, height)
      ..close();
    final lava = Path()
      ..moveTo(width * 0.42, height * 0.34)
      ..lineTo(width * 0.58, height * 0.34)
      ..lineTo(width * 0.55, height * 0.46)
      ..lineTo(width * 0.51, height * 0.4)
      ..lineTo(width * 0.47, height * 0.5)
      ..close();
    canvas
      ..drawPath(cone, _fill(_lavaRock))
      ..drawPath(lava, _fill(accentColor));
    for (final (centerX, centerY, radiusRatio) in const [
      (0.5, 0.24, 0.05),
      (0.56, 0.15, 0.065),
      (0.47, 0.07, 0.075),
    ]) {
      canvas.drawCircle(
        Offset(width * centerX, height * centerY),
        width * radiusRatio,
        _fill(_smokeColor),
      );
    }
  }

  void _paintWaves(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    canvas.drawRect(
      Rect.fromLTWH(0, height * 0.5, width, height * 0.5),
      _fill(_shade(accentColor, 0.15)),
    );
    final island = Path()
      ..moveTo(width * 0.62, height * 0.52)
      ..quadraticBezierTo(
        width * 0.75,
        height * 0.36,
        width * 0.9,
        height * 0.52,
      )
      ..close();
    canvas.drawPath(island, _fill(_shade(accentColor, 0.45)));
    final wavePaint = Paint()
      ..color = _tint(accentColor, 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2, height * 0.015)
      ..strokeCap = StrokeCap.round;
    for (var waveIndex = 0; waveIndex < _waveCount; waveIndex++) {
      final baseY = height * (0.58 + waveIndex * 0.07);
      final wave = Path()..moveTo(0, baseY);
      for (var step = 1; step <= 24; step++) {
        final x = width * step / 24;
        final y =
            baseY + math.sin(step * math.pi / 3 + waveIndex) * height * 0.012;
        wave.lineTo(x, y);
      }
      canvas.drawPath(wave, wavePaint);
    }
  }

  void _paintCity(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    const buildings = [
      (0.02, 0.12, 0.36),
      (0.15, 0.1, 0.5),
      (0.27, 0.14, 0.3),
      (0.43, 0.1, 0.56),
      (0.55, 0.12, 0.4),
      (0.69, 0.1, 0.62),
      (0.81, 0.16, 0.38),
    ];
    final groundLine = height * 0.8;
    for (var index = 0; index < buildings.length; index++) {
      final (left, buildingWidth, buildingHeight) = buildings[index];
      final rect = Rect.fromLTWH(
        width * left,
        groundLine - height * buildingHeight,
        width * buildingWidth,
        height * buildingHeight,
      );
      final buildingColor = index.isEven
          ? _shade(accentColor, 0.45)
          : _shade(accentColor, 0.3);
      canvas.drawRect(rect, _fill(buildingColor));
      _paintWindows(canvas, rect);
    }
  }

  void _paintWindows(Canvas canvas, Rect building) {
    final windowSide = building.width * 0.18;
    final windowPaint = _fill(_windowColor);
    for (
      var top = building.top + windowSide;
      top < building.bottom - windowSide * 2;
      top += windowSide * 2.2
    ) {
      canvas
        ..drawRect(
          Rect.fromLTWH(
            building.left + windowSide,
            top,
            windowSide,
            windowSide,
          ),
          windowPaint,
        )
        ..drawRect(
          Rect.fromLTWH(
            building.right - windowSide * 2,
            top,
            windowSide,
            windowSide,
          ),
          windowPaint,
        );
    }
  }

  void _paintTower(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    canvas.drawCircle(
      Offset(width * 0.2, height * 0.2),
      width * 0.07,
      _fill(_moonColor),
    );
    final hills = Path()
      ..moveTo(0, height * 0.7)
      ..quadraticBezierTo(width * 0.5, height * 0.52, width, height * 0.7)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas
      ..drawPath(hills, _fill(_shade(accentColor, 0.6)))
      ..drawRect(
        Rect.fromLTWH(width * 0.42, height * 0.22, width * 0.16, height * 0.6),
        _fill(_shade(accentColor, 0.45)),
      );
    final roof = Path()
      ..moveTo(width * 0.38, height * 0.23)
      ..lineTo(width * 0.5, height * 0.06)
      ..lineTo(width * 0.62, height * 0.23)
      ..close();
    canvas.drawPath(roof, _fill(_shade(accentColor, 0.25)));
    for (final windowY in const [0.32, 0.46, 0.6]) {
      canvas.drawRect(
        Rect.fromLTWH(
          width * 0.48,
          height * windowY,
          width * 0.04,
          height * 0.06,
        ),
        _fill(accentColor),
      );
    }
  }

  void _paintGround(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final ground = Path()
      ..moveTo(0, height * 0.82)
      ..quadraticBezierTo(width * 0.5, height * 0.74, width, height * 0.82)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(ground, _fill(_shade(accentColor, 0.5)));
  }

  @override
  bool shouldRepaint(ChapterSceneryPainter oldDelegate) =>
      oldDelegate.scenery != scenery || oldDelegate.accentColor != accentColor;
}
