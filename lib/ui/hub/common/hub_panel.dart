import 'package:flutter/material.dart';

import '../hub_style.dart';

class HubPanel extends StatelessWidget {
  const HubPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor = HubStyle.panelBorder,
    this.radius = HubStyle.panelRadius,
    this.gradient = HubStyle.panelGradient,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final double radius;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: HubStyle.panelDecoration(
        borderColor: borderColor,
        radius: radius,
        gradient: gradient,
      ),
      child: child,
    );
  }
}
