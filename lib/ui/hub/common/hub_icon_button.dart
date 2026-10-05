import 'package:flutter/material.dart';

import '../hub_style.dart';
import 'hub_layout.dart';

class HubIconButton extends StatelessWidget {
  const HubIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticLabel,
      excludeSemantics: true,
      child: Tooltip(
        message: semanticLabel,
        child: Material(
          color: isEnabled ? HubStyle.activeTabBottom : HubStyle.navigationBar,
          shape: const CircleBorder(
            side: BorderSide(color: HubStyle.panelBorder, width: 2),
          ),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: HubLayout.minTouchTarget,
              child: Icon(
                icon,
                color: isEnabled ? HubStyle.white : HubStyle.locked,
                shadows: const [
                  Shadow(offset: Offset(0, 2), color: HubStyle.navy),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
