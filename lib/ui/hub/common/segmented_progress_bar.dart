import 'package:flutter/material.dart';

import '../hub_style.dart';

class SegmentedProgressBar extends StatelessWidget {
  const SegmentedProgressBar({
    required this.filledCount,
    required this.totalCount,
    required this.color,
    super.key,
  });

  static const _height = 10.0;
  static const _gap = 3.0;

  final int filledCount;
  final int totalCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: _height,
        child: Row(
          children: [
            for (var segment = 0; segment < totalCount; segment++) ...[
              if (segment > 0) const SizedBox(width: _gap),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: segment < filledCount ? color : HubStyle.deepNavy,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: HubStyle.navy),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
