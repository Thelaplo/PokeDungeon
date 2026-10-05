import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/frame_steps.dart';

double totalOf(List<double> steps) =>
    steps.fold(0, (total, stepTime) => total + stepTime);

void main() {
  test('a regular frame runs as a single step', () {
    expect(FrameSteps.split(1 / 60), hasLength(1));
    expect(totalOf(FrameSteps.split(1 / 60)), closeTo(1 / 60, 1e-9));
  });

  test('a long frame is split into small equal steps', () {
    final steps = FrameSteps.split(0.1);

    expect(totalOf(steps), closeTo(0.1, 1e-9));
    for (final stepTime in steps) {
      expect(stepTime, lessThanOrEqualTo(FrameSteps.maxStepTime + 1e-9));
    }
  });

  test('a throttled frame only simulates a quarter of a second', () {
    final steps = FrameSteps.split(3);

    expect(totalOf(steps), closeTo(FrameSteps.maxFrameTime, 1e-9));
    expect(
      steps.every((stepTime) => stepTime <= FrameSteps.maxStepTime + 1e-9),
      isTrue,
    );
  });

  test('an empty or broken frame still runs one zero step', () {
    expect(FrameSteps.split(0), [0]);
    expect(FrameSteps.split(-1), [0]);
    expect(FrameSteps.split(double.nan), [0]);
  });
}
