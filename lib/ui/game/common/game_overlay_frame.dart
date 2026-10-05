import 'package:flutter/material.dart';

import '../../hub/hub_style.dart';

class GameOverlayFrame extends StatelessWidget {
  const GameOverlayFrame({
    required this.child,
    this.maxWidth = 440,
    this.borderColor = HubStyle.panelBorder,
    super.key,
  });

  static const scrimColor = Color(0xCC08181E);
  static const _radius = 24.0;

  final Widget child;
  final double maxWidth;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: scrimColor,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: HubStyle.panelDecoration(
                  borderColor: borderColor,
                  radius: _radius,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
