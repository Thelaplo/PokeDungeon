import 'package:flutter/material.dart';

import '../hub_style.dart';
import 'hub_tab.dart';

class HubNavigationButton extends StatelessWidget {
  const HubNavigationButton({
    required this.tab,
    required this.isSelected,
    required this.hasBadge,
    required this.onTap,
    super.key,
  });

  static const _idleHeight = 64.0;
  static const _selectedHeight = 80.0;
  static const _idleIconSize = 28.0;
  static const _selectedIconSize = 40.0;
  static const _featuredIconBoost = 4.0;
  static const _animationDuration = Duration(milliseconds: 180);
  static const _radius = 16.0;
  static const _iconShadows = [
    Shadow(offset: Offset(0, 2), color: HubStyle.navy),
  ];

  final HubTab tab;
  final bool isSelected;
  final bool hasBadge;
  final VoidCallback onTap;

  double get _iconSize {
    final baseSize = isSelected ? _selectedIconSize : _idleIconSize;
    return tab.isFeatured ? baseSize + _featuredIconBoost : baseSize;
  }

  String get _semanticLabel =>
      hasBadge ? '${tab.label}, récompense à réclamer' : tab.label;

  BoxDecoration get _decoration {
    if (!isSelected) {
      return BoxDecoration(borderRadius: BorderRadius.circular(_radius));
    }
    return BoxDecoration(
      gradient: HubStyle.activeTabGradient,
      borderRadius: BorderRadius.circular(_radius),
      border: Border.all(color: HubStyle.accent, width: 2),
      boxShadow: [
        BoxShadow(
          color: HubStyle.accent.withValues(alpha: 0.45),
          blurRadius: 14,
        ),
        const BoxShadow(color: HubStyle.deepNavy, offset: Offset(0, 4)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: _semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: _animationDuration,
          curve: Curves.easeOutCubic,
          height: isSelected ? _selectedHeight : _idleHeight,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: _decoration,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    tab.icon,
                    size: _iconSize,
                    color: HubStyle.white,
                    shadows: _iconShadows,
                  ),
                  if (hasBadge)
                    const Positioned(top: -4, right: -8, child: _AlertBadge()),
                ],
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  tab.label,
                  style: HubStyle.title(
                    fontSize: 12,
                    color: isSelected ? HubStyle.accent : HubStyle.softText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertBadge extends StatelessWidget {
  const _AlertBadge();

  static const _side = 18.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _side,
      height: _side,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: HubStyle.danger,
        shape: BoxShape.circle,
        border: Border.all(color: HubStyle.white, width: 2),
      ),
      child: Text('!', style: HubStyle.plainTitle(fontSize: 11)),
    );
  }
}
