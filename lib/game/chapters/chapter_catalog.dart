import '../../models/chapter.dart';

abstract final class ChapterCatalog {
  static const all = [
    Chapter(
      number: 1,
      name: 'Forêt de Jade',
      subtitle: 'Plante · Insecte · Normal',
      pokemonTypes: ['grass', 'bug', 'normal'],
      difficulty: 1.0,
      finalBossId: 3,
    ),
    Chapter(
      number: 2,
      name: 'Mont Sélénite',
      subtitle: 'Roche · Sol · Combat',
      pokemonTypes: ['rock', 'ground', 'fighting'],
      difficulty: 1.4,
      finalBossId: 76,
    ),
    Chapter(
      number: 3,
      name: 'Volcan Cramois\'Île',
      subtitle: 'Feu · Combat · Sol',
      pokemonTypes: ['fire', 'fighting', 'ground'],
      difficulty: 1.9,
      finalBossId: 6,
    ),
    Chapter(
      number: 4,
      name: 'Îles Écume',
      subtitle: 'Eau · Glace',
      pokemonTypes: ['water', 'ice'],
      difficulty: 2.5,
      finalBossId: 130,
    ),
    Chapter(
      number: 5,
      name: 'Safrania',
      subtitle: 'Électrik · Psy',
      pokemonTypes: ['electric', 'psychic'],
      difficulty: 3.2,
      finalBossId: 65,
    ),
    Chapter(
      number: 6,
      name: 'Tour Pokémon',
      subtitle: 'Spectre · Poison',
      pokemonTypes: ['ghost', 'poison'],
      difficulty: 4.0,
      finalBossId: 94,
    ),
  ];

  static Chapter byNumber(int number) =>
      all.firstWhere((chapter) => chapter.number == number);
}
