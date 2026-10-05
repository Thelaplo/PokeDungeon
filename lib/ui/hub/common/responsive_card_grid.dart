import 'package:flutter/material.dart';

class ResponsiveCardGrid extends StatelessWidget {
  const ResponsiveCardGrid({
    required this.children,
    this.minCardWidth = 150,
    this.spacing = 10,
    super.key,
  });

  final List<Widget> children;
  final double minCardWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount =
            ((constraints.maxWidth + spacing) / (minCardWidth + spacing))
                .floor()
                .clamp(1, children.isEmpty ? 1 : children.length);
        final cardWidth =
            (constraints.maxWidth - spacing * (columnCount - 1)) / columnCount;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: cardWidth, child: child),
          ],
        );
      },
    );
  }
}
