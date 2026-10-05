import 'package:flutter/material.dart';

import '../hub_style.dart';

class HubDialogFrame extends StatelessWidget {
  const HubDialogFrame({
    required this.child,
    this.borderColor = HubStyle.panelBorder,
    super.key,
  });

  static const _maxDialogWidth = 420.0;

  final Widget child;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxDialogWidth),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: HubStyle.panelDecoration(
            borderColor: borderColor,
            radius: 22,
          ),
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
  }
}
