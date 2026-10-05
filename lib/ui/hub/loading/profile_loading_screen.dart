import 'package:flutter/material.dart';

import '../common/hub_background.dart';
import '../common/poke_ball_icon.dart';
import '../hub_style.dart';
import 'game_title.dart';

class ProfileLoadingScreen extends StatefulWidget {
  const ProfileLoadingScreen({super.key});

  @override
  State<ProfileLoadingScreen> createState() => _ProfileLoadingScreenState();
}

class _ProfileLoadingScreenState extends State<ProfileLoadingScreen>
    with SingleTickerProviderStateMixin {
  static const _spinDuration = Duration(milliseconds: 1100);
  static const _ballSize = 72.0;

  late final AnimationController _spinController = AnimationController(
    vsync: this,
    duration: _spinDuration,
  )..repeat();

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HubBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GameTitle(),
                const SizedBox(height: 40),
                RotationTransition(
                  turns: _spinController,
                  child: const PokeBallIcon(size: _ballSize),
                ),
                const SizedBox(height: 24),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'Chargement de ta sauvegarde...',
                    textAlign: TextAlign.center,
                    style: HubStyle.body(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
