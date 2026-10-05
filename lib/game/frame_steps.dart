import 'dart:math';

abstract final class FrameSteps {
  static const maxFrameTime = 0.25;
  static const maxStepTime = 1 / 60;

  static List<double> split(double frameTime) {
    if (frameTime.isNaN || frameTime <= 0) {
      return const [0];
    }
    final simulatedTime = min(frameTime, maxFrameTime);
    final stepCount = (simulatedTime / maxStepTime).ceil();
    final stepTime = simulatedTime / stepCount;
    return List.filled(stepCount, stepTime);
  }
}
