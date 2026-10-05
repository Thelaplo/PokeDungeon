import 'package:flutter/material.dart';

import '../../../profile/player_profile.dart';
import '../../../services/poke_api_service.dart';
import '../hub_screen.dart';
import '../loading/profile_error_screen.dart';
import '../loading/profile_loading_screen.dart';

class ProfileGateView extends StatelessWidget {
  const ProfileGateView({
    required this.profileLoading,
    required this.api,
    required this.onRetry,
    super.key,
  });

  final Future<PlayerProfile> profileLoading;
  final PokeApiService api;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlayerProfile>(
      future: profileLoading,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const ProfileLoadingScreen();
        }
        final profile = snapshot.data;
        if (snapshot.hasError || profile == null) {
          return ProfileErrorScreen(onRetry: onRetry);
        }
        return HubScreen(profile: profile, api: api);
      },
    );
  }
}
