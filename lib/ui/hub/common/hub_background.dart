import 'package:flutter/material.dart';

import '../hub_style.dart';

class HubBackground extends StatelessWidget {
  const HubBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: HubStyle.backgroundGradient),
      child: child,
    );
  }
}
