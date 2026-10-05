import 'package:flutter/material.dart';

import '../../hub/hub_style.dart';

class GameMessageBubble extends StatelessWidget {
  const GameMessageBubble({
    required this.message,
    this.borderColor = HubStyle.panelBorder,
    this.textColor = HubStyle.white,
    super.key,
  });

  static const _maxWidth = 420.0;

  final ValueNotifier<String?> message;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: message,
      builder: (context, text, _) {
        if (text == null) {
          return const SizedBox.shrink();
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: HubStyle.panelDecoration(
                borderColor: borderColor,
                radius: 24,
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: HubStyle.title(fontSize: 17, color: textColor),
              ),
            ),
          ),
        );
      },
    );
  }
}
