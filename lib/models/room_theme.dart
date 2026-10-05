import 'dart:ui';

class RoomTheme {
  const RoomTheme({
    required this.pokemonType,
    required this.roomName,
    required this.floorColor,
    required this.floorAltColor,
    required this.wallColor,
    required this.accentColor,
  });

  final String pokemonType;
  final String roomName;
  final Color floorColor;
  final Color floorAltColor;
  final Color wallColor;
  final Color accentColor;

  static const crypt = RoomTheme(
    pokemonType: 'normal',
    roomName: 'Crypte',
    floorColor: Color(0xFF22222E),
    floorAltColor: Color(0xFF1C1C26),
    wallColor: Color(0xFF3A3A4E),
    accentColor: Color(0xFFB8B8D0),
  );

  static RoomTheme forType(String pokemonType) => all.firstWhere(
    (theme) => theme.pokemonType == pokemonType,
    orElse: () => crypt,
  );

  static const all = [
    crypt,
    RoomTheme(
      pokemonType: 'fire',
      roomName: 'Volcan',
      floorColor: Color(0xFF3A1A12),
      floorAltColor: Color(0xFF30140E),
      wallColor: Color(0xFF7A2A10),
      accentColor: Color(0xFFFF7A2A),
    ),
    RoomTheme(
      pokemonType: 'water',
      roomName: 'Grotte inondée',
      floorColor: Color(0xFF102438),
      floorAltColor: Color(0xFF0C1E30),
      wallColor: Color(0xFF1E4A70),
      accentColor: Color(0xFF4AB8FF),
    ),
    RoomTheme(
      pokemonType: 'grass',
      roomName: 'Jungle',
      floorColor: Color(0xFF15301A),
      floorAltColor: Color(0xFF112814),
      wallColor: Color(0xFF2C5A22),
      accentColor: Color(0xFF7CE05A),
    ),
    RoomTheme(
      pokemonType: 'electric',
      roomName: 'Centrale',
      floorColor: Color(0xFF2E2A12),
      floorAltColor: Color(0xFF26220E),
      wallColor: Color(0xFF5E5418),
      accentColor: Color(0xFFFFE040),
    ),
    RoomTheme(
      pokemonType: 'poison',
      roomName: 'Marais toxique',
      floorColor: Color(0xFF28142E),
      floorAltColor: Color(0xFF221028),
      wallColor: Color(0xFF52265E),
      accentColor: Color(0xFFC060F0),
    ),
    RoomTheme(
      pokemonType: 'ground',
      roomName: 'Canyon',
      floorColor: Color(0xFF33281A),
      floorAltColor: Color(0xFF2B2115),
      wallColor: Color(0xFF6A5030),
      accentColor: Color(0xFFE0B060),
    ),
    RoomTheme(
      pokemonType: 'psychic',
      roomName: 'Temple psychique',
      floorColor: Color(0xFF301628),
      floorAltColor: Color(0xFF281222),
      wallColor: Color(0xFF6A2A58),
      accentColor: Color(0xFFFF6AC8),
    ),
    RoomTheme(
      pokemonType: 'ghost',
      roomName: 'Tour hantée',
      floorColor: Color(0xFF1A1630),
      floorAltColor: Color(0xFF151228),
      wallColor: Color(0xFF3A2E6A),
      accentColor: Color(0xFF9A80FF),
    ),
    RoomTheme(
      pokemonType: 'ice',
      roomName: 'Caverne gelée',
      floorColor: Color(0xFF1A2C36),
      floorAltColor: Color(0xFF16252E),
      wallColor: Color(0xFF3E6A80),
      accentColor: Color(0xFFA0F0FF),
    ),
    RoomTheme(
      pokemonType: 'rock',
      roomName: 'Mine abandonnée',
      floorColor: Color(0xFF2A2620),
      floorAltColor: Color(0xFF231F1A),
      wallColor: Color(0xFF575040),
      accentColor: Color(0xFFC8B890),
    ),
    RoomTheme(
      pokemonType: 'bug',
      roomName: 'Nid d\'insectes',
      floorColor: Color(0xFF242C12),
      floorAltColor: Color(0xFF1E250E),
      wallColor: Color(0xFF4C5A1E),
      accentColor: Color(0xFFB8E040),
    ),
    RoomTheme(
      pokemonType: 'fighting',
      roomName: 'Dojo',
      floorColor: Color(0xFF301A14),
      floorAltColor: Color(0xFF281510),
      wallColor: Color(0xFF6A3420),
      accentColor: Color(0xFFFF9060),
    ),
  ];
}
