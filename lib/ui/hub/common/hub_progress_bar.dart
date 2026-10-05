import 'package:flutter/material.dart';

import '../hub_style.dart';

class HubProgressBar extends StatelessWidget {
  const HubProgressBar({
    required this.ratio,
    this.gradient = HubStyle.progressGradient,
    this.height = 12,
    super.key,
  });

  final double ratio;
  final Gradient gradient;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: HubStyle.deepNavy,
        borderRadius: radius,
        border: Border.all(color: HubStyle.navy, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: ratio.clamp(0.0, 1.0),
            heightFactor: 1,
            child: DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
          ),
        ),
      ),
    );
  }
}
