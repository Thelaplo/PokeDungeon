import 'package:flutter/material.dart';

import '../common/hub_background.dart';
import '../common/hub_button.dart';
import '../common/hub_panel.dart';
import '../hub_style.dart';
import 'game_title.dart';

class ProfileErrorScreen extends StatelessWidget {
  const ProfileErrorScreen({required this.onRetry, super.key});

  static const _maxPanelWidth = 420.0;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HubBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const GameTitle(),
                  const SizedBox(height: 32),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxPanelWidth),
                    child: HubPanel(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            size: 48,
                            color: HubStyle.danger,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Oups ! Impossible de charger ta sauvegarde.',
                            textAlign: TextAlign.center,
                            style: HubStyle.title(fontSize: 20),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vérifie le stockage de l\'appareil puis réessaie.',
                            textAlign: TextAlign.center,
                            style: HubStyle.body(color: HubStyle.mutedText),
                          ),
                          const SizedBox(height: 20),
                          HubButton(label: 'RÉESSAYER', onPressed: onRetry),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
