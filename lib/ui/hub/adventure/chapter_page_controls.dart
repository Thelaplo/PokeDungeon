import 'package:flutter/material.dart';

import '../common/hub_icon_button.dart';
import '../hub_style.dart';

class ChapterPageControls extends StatelessWidget {
  const ChapterPageControls({
    required this.pageCount,
    required this.selectedIndex,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  static const _dotSide = 10.0;
  static const _selectedDotWidth = 24.0;
  static const _dotDuration = Duration(milliseconds: 200);

  final int pageCount;
  final int selectedIndex;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HubIconButton(
          icon: Icons.chevron_left_rounded,
          semanticLabel: 'Chapitre précédent',
          onPressed: onPrevious,
        ),
        Expanded(
          child: Semantics(
            label: 'Chapitre ${selectedIndex + 1} sur $pageCount',
            excludeSemantics: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < pageCount; index++)
                  AnimatedContainer(
                    duration: _dotDuration,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: index == selectedIndex
                        ? _selectedDotWidth
                        : _dotSide,
                    height: _dotSide,
                    decoration: BoxDecoration(
                      color: index == selectedIndex
                          ? HubStyle.accent
                          : HubStyle.deepNavy,
                      borderRadius: BorderRadius.circular(_dotSide),
                      border: Border.all(color: HubStyle.panelBorder),
                    ),
                  ),
              ],
            ),
          ),
        ),
        HubIconButton(
          icon: Icons.chevron_right_rounded,
          semanticLabel: 'Chapitre suivant',
          onPressed: onNext,
        ),
      ],
    );
  }
}
