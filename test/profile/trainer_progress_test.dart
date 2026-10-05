import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/profile/trainer_progress.dart';

void main() {
  test('xp required grows with each level', () {
    expect(TrainerProgress.xpRequiredAt(1), 100);
    expect(TrainerProgress.xpRequiredAt(2), 160);
    expect(TrainerProgress.xpRequiredAt(3), 220);
  });

  test('xp below the threshold stays in the current level', () {
    final progress = TrainerProgress.initial.addXp(99);

    expect(progress.level, 1);
    expect(progress.xpIntoLevel, 99);
  });

  test('xp overflowing several thresholds gains several levels', () {
    final progress = TrainerProgress.initial.addXp(100 + 160 + 30);

    expect(progress.level, 3);
    expect(progress.xpIntoLevel, 30);
    expect(progress.xpForNextLevel, 220);
  });

  test('non positive xp leaves progress unchanged', () {
    expect(TrainerProgress.initial.addXp(0), same(TrainerProgress.initial));
    expect(TrainerProgress.initial.addXp(-5), same(TrainerProgress.initial));
  });
}
