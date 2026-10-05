import 'item_definition.dart';

class ActiveBoost {
  ActiveBoost({required this.item}) : remainingSeconds = item.boostDuration;

  final ConsumableItem item;
  double remainingSeconds;

  bool get isExpired => remainingSeconds <= 0;

  int get displayedSeconds => remainingSeconds.ceil();
}
