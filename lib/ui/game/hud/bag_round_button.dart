import 'package:flutter/material.dart';

import '../../hub/common/hub_button_variant.dart';
import '../../hub/hub_style.dart';

class BagRoundButton extends StatelessWidget {
  const BagRoundButton({required this.onPressed, super.key});

  static const _side = 68.0;
  static const _lipHeight = 5.0;
  static const _variant = HubButtonVariant.info;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ouvrir le sac',
      excludeSemantics: true,
      child: Tooltip(
        message: 'Sac (I)',
        child: Container(
          width: _side,
          height: _side + _lipHeight,
          padding: const EdgeInsets.only(bottom: _lipHeight),
          decoration: BoxDecoration(
            color: _variant.lipColor,
            shape: BoxShape.circle,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Ink(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _variant.gradient,
                  border: Border.all(
                    color: HubStyle.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.backpack_rounded,
                      color: HubStyle.white,
                      size: 26,
                      shadows: [
                        Shadow(offset: Offset(0, 2), color: HubStyle.navy),
                      ],
                    ),
                    Text(
                      'Sac',
                      style: HubStyle.title(
                        fontSize: 13,
                        outlineColor: _variant.lipColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
