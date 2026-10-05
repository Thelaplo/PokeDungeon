import 'room_theme.dart';

class Chapter {
  const Chapter({
    required this.number,
    required this.name,
    required this.subtitle,
    required this.pokemonTypes,
    required this.difficulty,
    required this.finalBossId,
    this.roomCount = 10,
    this.miniBossRoom = 5,
  });

  final int number;
  final String name;
  final String subtitle;
  final List<String> pokemonTypes;
  final double difficulty;
  final int finalBossId;
  final int roomCount;
  final int miniBossRoom;

  List<RoomTheme> get themes => pokemonTypes.map(RoomTheme.forType).toList();

  bool isFinalBossRoom(int room) => room == roomCount;

  bool isMiniBossRoom(int room) => room == miniBossRoom;
}
