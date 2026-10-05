import 'package:flutter/material.dart';

import 'profile/player_profile.dart';
import 'services/poke_api_service.dart';
import 'ui/hub/app/hub_scroll_behavior.dart';
import 'ui/hub/app/hub_theme.dart';
import 'ui/hub/app/profile_gate_view.dart';

void main() {
  runApp(const PokeDungeonApp());
}

class PokeDungeonApp extends StatefulWidget {
  const PokeDungeonApp({super.key});

  @override
  State<PokeDungeonApp> createState() => _PokeDungeonAppState();
}

class _PokeDungeonAppState extends State<PokeDungeonApp> {
  final PokeApiService _api = PokeApiService();
  late Future<PlayerProfile> _profileLoading = _loadProfile();
  PlayerProfile? _loadedProfile;

  Future<PlayerProfile> _loadProfile() async {
    final profile = await PlayerProfile.load();
    _loadedProfile = profile;
    return profile;
  }

  void _retryLoading() {
    setState(() => _profileLoading = _loadProfile());
  }

  @override
  void dispose() {
    _loadedProfile?.dispose();
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poké Dungeon',
      debugShowCheckedModeBanner: false,
      theme: HubTheme.dark(),
      darkTheme: HubTheme.dark(),
      themeMode: ThemeMode.dark,
      scrollBehavior: const HubScrollBehavior(),
      home: ProfileGateView(
        profileLoading: _profileLoading,
        api: _api,
        onRetry: _retryLoading,
      ),
    );
  }
}
