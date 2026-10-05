import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/items/item_catalog.dart';
import 'package:poke_dungeon/game/skills/skill_catalog.dart';
import 'package:poke_dungeon/models/item_definition.dart';
import 'package:poke_dungeon/models/player_stats.dart';
import 'package:poke_dungeon/models/run_config.dart';

PlayerStats statsWith(EquipmentItem item, {required int level}) =>
    PlayerStats.from(
      EquipmentLoadout({item.slot: OwnedEquipment(item: item, level: level)})
          .modifiers,
    );

void main() {
  test('no equipment gives the base stats', () {
    final stats = PlayerStats.from(EquipmentLoadout.empty.modifiers);

    expect(stats.maxHp, PlayerStats.baseMaxHp);
    expect(stats.damage, PlayerStats.baseDamage);
    expect(stats.projectileCount, 1);
  });

  test('level one equipment gives its base bonus', () {
    expect(
      statsWith(ItemCatalog.charcoal, level: 1).damage,
      PlayerStats.baseDamage + 5,
    );
  });

  test('upgraded equipment gives a bigger bonus', () {
    final levelOneDamage = statsWith(ItemCatalog.charcoal, level: 1).damage;
    final levelTenDamage = statsWith(ItemCatalog.charcoal, level: 10).damage;

    expect(levelTenDamage, PlayerStats.baseDamage + 12);
    expect(levelTenDamage, greaterThan(levelOneDamage));
  });

  test('levels above the maximum are capped', () {
    expect(
      statsWith(ItemCatalog.hardStone, level: 99).maxHp,
      statsWith(ItemCatalog.hardStone, level: EquipmentItem.maxLevel).maxHp,
    );
  });

  test('extra projectiles and penalties do not grow with the level', () {
    final levelOne = statsWith(ItemCatalog.wideLens, level: 1);
    final levelTen = statsWith(ItemCatalog.wideLens, level: 10);

    expect(levelTen.projectileCount, levelOne.projectileCount);
    expect(levelTen.damage, levelOne.damage);
  });

  test('damage reduction stays capped with upgraded armor', () {
    final stats = PlayerStats.from([
      ItemCatalog.assaultVest.modifiersAtLevel(10),
      SkillCatalog.armor.modifiers,
      SkillCatalog.armor.modifiers,
      SkillCatalog.armor.modifiers,
    ]);

    expect(stats.damageReduction, PlayerStats.maxDamageReduction);
  });

  test('equipment and skills stack together', () {
    final stats = PlayerStats.from([
      ...EquipmentLoadout({
        EquipmentSlot.defense: OwnedEquipment(
          item: ItemCatalog.hardStone,
          level: 5,
        ),
      }).modifiers,
      SkillCatalog.vitality.modifiers,
    ]);

    expect(stats.maxHp, PlayerStats.baseMaxHp + 32 + 25);
  });
}
