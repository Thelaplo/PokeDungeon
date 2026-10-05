import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class PixelStyle {
  static const ink = Color(0xFF101018);
  static const paper = Color(0xFFF8F8F8);
  static const danger = Color(0xFFE83838);
  static const gold = Color(0xFFFFD040);
  static const panel = Color(0xE6181822);

  static TextStyle text({double fontSize = 12, Color color = paper}) =>
      GoogleFonts.pressStart2p(
        fontSize: fontSize,
        color: color,
        height: 1.4,
        shadows: const [Shadow(offset: Offset(2, 2), color: ink)],
      );

  static BoxDecoration panelDecoration({Color borderColor = paper}) =>
      BoxDecoration(
        color: panel,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: const [BoxShadow(color: ink, offset: Offset(4, 4))],
      );
}

class PixelButton extends StatelessWidget {
  const PixelButton({
    required this.label,
    required this.onPressed,
    this.isCompact = false,
    this.color = PixelStyle.danger,
    super.key,
  });

  static const _disabledColor = Color(0xFF4A4A5A);

  final String label;
  final VoidCallback? onPressed;
  final bool isCompact;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: isEnabled ? color : _disabledColor,
        shape: const BeveledRectangleBorder(
          side: BorderSide(color: PixelStyle.ink, width: 3),
        ),
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            child: Padding(
              padding: isCompact
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
                  : const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: PixelStyle.text(
                  fontSize: isCompact ? 9 : 16,
                  color: isEnabled ? PixelStyle.paper : const Color(0xFFA0A0B0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PixelBar extends StatelessWidget {
  const PixelBar({
    required this.ratio,
    required this.color,
    this.height = 14,
    super.key,
  });

  final double ratio;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF3A1010),
        border: Border.all(color: PixelStyle.ink, width: 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: ratio.clamp(0.0, 1.0),
        child: ColoredBox(color: color),
      ),
    );
  }
}
