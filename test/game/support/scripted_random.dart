import 'dart:math';

class ScriptedRandom implements Random {
  ScriptedRandom(List<double> doubles) : _doubles = List.of(doubles);

  final List<double> _doubles;

  @override
  double nextDouble() => _doubles.isEmpty ? 0.99 : _doubles.removeAt(0);

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => false;
}
