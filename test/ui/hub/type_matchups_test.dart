import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/chapters/chapter_catalog.dart';
import 'package:poke_dungeon/game/heroes/hero_catalog.dart';
import 'package:poke_dungeon/models/hero_definition.dart';
import 'package:poke_dungeon/models/pokemon_type.dart';
import 'package:poke_dungeon/ui/hub/common/type_matchups.dart';

bool _onlyTrainerUnlocked(HeroDefinition hero) =>
    hero.id == HeroCatalog.trainer.id;

void main() {
  final jadeForestTypes = TypeMatchups.chapterTypes(ChapterCatalog.byNumber(1));
  final moonstoneTypes = TypeMatchups.chapterTypes(ChapterCatalog.byNumber(2));

  test('chapter api type names map to pokemon types', () {
    expect(jadeForestTypes, [
      PokemonType.grass,
      PokemonType.bug,
      PokemonType.normal,
    ]);
  });

  test('fire hits grass, ice, bug and steel super effectively', () {
    expect(TypeMatchups.superEffectiveTargetsOf(PokemonType.fire), [
      PokemonType.grass,
      PokemonType.ice,
      PokemonType.bug,
      PokemonType.steel,
    ]);
  });

  test('normal type is strong against nothing', () {
    expect(TypeMatchups.superEffectiveTargetsOf(PokemonType.normal), isEmpty);
  });

  test('recommends only heroes with super effective coverage', () {
    final recommended = TypeMatchups.recommendedHeroes(
      chapterTypes: jadeForestTypes,
      heroes: HeroCatalog.all,
      isUnlocked: _onlyTrainerUnlocked,
    );

    expect(recommended, [HeroCatalog.charmander]);
  });

  test('ranks by coverage then catalog order when all are locked', () {
    final recommended = TypeMatchups.recommendedHeroes(
      chapterTypes: moonstoneTypes,
      heroes: HeroCatalog.all,
      isUnlocked: _onlyTrainerUnlocked,
    );

    expect(recommended, [
      HeroCatalog.squirtle,
      HeroCatalog.bulbasaur,
      HeroCatalog.mewtwo,
    ]);
  });

  test('puts unlocked heroes first', () {
    final recommended = TypeMatchups.recommendedHeroes(
      chapterTypes: moonstoneTypes,
      heroes: HeroCatalog.all,
      isUnlocked: (hero) =>
          hero.id == HeroCatalog.mewtwo.id ||
          hero.id == HeroCatalog.bulbasaur.id,
    );

    expect(recommended, [
      HeroCatalog.bulbasaur,
      HeroCatalog.mewtwo,
      HeroCatalog.squirtle,
    ]);
  });

  test('respects the recommendation limit', () {
    final recommended = TypeMatchups.recommendedHeroes(
      chapterTypes: moonstoneTypes,
      heroes: HeroCatalog.all,
      isUnlocked: _onlyTrainerUnlocked,
      limit: 1,
    );

    expect(recommended, [HeroCatalog.squirtle]);
  });

  test('detects when chapter types hit the hero super effectively', () {
    expect(
      TypeMatchups.isVulnerable(HeroCatalog.trainer, moonstoneTypes),
      isTrue,
    );
    expect(
      TypeMatchups.isVulnerable(HeroCatalog.trainer, jadeForestTypes),
      isFalse,
    );
    expect(
      TypeMatchups.isVulnerable(HeroCatalog.charmander, moonstoneTypes),
      isTrue,
    );
    expect(
      TypeMatchups.isVulnerable(HeroCatalog.squirtle, moonstoneTypes),
      isFalse,
    );
  });
}
