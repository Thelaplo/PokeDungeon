import 'package:flutter/material.dart';

import 'hub_layout.dart';

class HubContentFrame extends StatelessWidget {
  const HubContentFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: HubLayout.maxContentWidth),
        child: child,
      ),
    );
  }
}
