import '../../../models/chapter.dart';
import '../../../models/hero_definition.dart';
import '../../../models/pokemon_type.dart';

abstract final class TypeMatchups {
  static const recommendedHeroLimit = 3;

  static List<PokemonType> chapterTypes(Chapter chapter) => [
    for (final apiName in chapter.pokemonTypes)
      ?PokemonType.fromApiName(apiName),
  ];

  static List<PokemonType> superEffectiveTargetsOf(PokemonType attacking) => [
    for (final defending in PokemonType.values)
      if (TypeChart.multiplierAgainstOne(attacking, defending) > 1) defending,
  ];

  static int coverageOf(HeroDefinition hero, List<PokemonType> chapterTypes) =>
      chapterTypes
          .where(
            (chapterType) =>
                TypeChart.multiplierAgainstOne(hero.type, chapterType) > 1,
          )
          .length;

  static bool isVulnerable(
    HeroDefinition hero,
    List<PokemonType> chapterTypes,
  ) => chapterTypes.any(
    (chapterType) => TypeChart.multiplierAgainstOne(chapterType, hero.type) > 1,
  );

  static List<HeroDefinition> recommendedHeroes({
    required List<PokemonType> chapterTypes,
    required List<HeroDefinition> heroes,
    required bool Function(HeroDefinition hero) isUnlocked,
    int limit = recommendedHeroLimit,
  }) {
    final candidates = [
      for (var index = 0; index < heroes.length; index++)
        if (coverageOf(heroes[index], chapterTypes) > 0)
          (
            hero: heroes[index],
            catalogIndex: index,
            coverage: coverageOf(heroes[index], chapterTypes),
            isUnlocked: isUnlocked(heroes[index]),
          ),
    ];
    candidates.sort((first, second) {
      if (first.isUnlocked != second.isUnlocked) {
        return first.isUnlocked ? -1 : 1;
      }
      if (first.coverage != second.coverage) {
        return second.coverage.compareTo(first.coverage);
      }
      return first.catalogIndex.compareTo(second.catalogIndex);
    });
    return [for (final candidate in candidates.take(limit)) candidate.hero];
  }
}
