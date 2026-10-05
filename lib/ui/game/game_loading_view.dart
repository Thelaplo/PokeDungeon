import 'package:flutter/material.dart';

import '../hub/common/hub_background.dart';
import '../hub/hub_style.dart';

class GameLoadingView extends StatelessWidget {
  const GameLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return HubBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox.square(
              dimension: 48,
              child: CircularProgressIndicator(
                color: HubStyle.accent,
                strokeWidth: 5,
              ),
            ),
            const SizedBox(height: 16),
            Text('Chargement…', style: HubStyle.title(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
