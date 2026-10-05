import '../../../models/chapter.dart';

enum ChapterScenery {
  hills,
  mountains,
  volcano,
  waves,
  city,
  tower;

  bool get isNight => this == tower;

  static ChapterScenery forChapter(Chapter chapter) =>
      switch (chapter.pokemonTypes.first) {
        'rock' || 'ground' || 'fighting' => mountains,
        'fire' => volcano,
        'water' || 'ice' => waves,
        'electric' || 'psychic' => city,
        'ghost' || 'poison' => tower,
        _ => hills,
      };
}
