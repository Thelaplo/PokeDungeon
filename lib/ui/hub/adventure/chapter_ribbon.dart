import 'package:flutter/material.dart';

import '../hub_style.dart';

class ChapterRibbon extends StatelessWidget {
  const ChapterRibbon({
    required this.chapterNumber,
    required this.chapterName,
    required this.color,
    super.key,
  });

  final int chapterNumber;
  final String chapterName;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RibbonPainter(color: color),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 6, 36, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CHAPITRE $chapterNumber',
              style: HubStyle.title(fontSize: 12, color: HubStyle.accent),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(chapterName, style: HubStyle.title(fontSize: 22)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  const _RibbonPainter({required this.color});

  static const _notchRatio = 0.12;
  static const _outlineWidth = 2.5;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final notch = size.width * _notchRatio;
    final ribbon = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - notch, size.height / 2)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(notch, size.height / 2)
      ..close();
    final rect = Offset.zero & size;
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(color, Colors.black, 0.15) ?? color,
          Color.lerp(color, Colors.black, 0.45) ?? color,
        ],
      ).createShader(rect);
    final outline = Paint()
      ..color = HubStyle.navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = _outlineWidth
      ..strokeJoin = StrokeJoin.round;
    canvas
      ..drawPath(
        ribbon.shift(const Offset(0, 4)),
        Paint()..color = HubStyle.deepNavy,
      )
      ..drawPath(ribbon, fill)
      ..drawPath(ribbon, outline);
  }

  @override
  bool shouldRepaint(_RibbonPainter oldDelegate) => oldDelegate.color != color;
}
