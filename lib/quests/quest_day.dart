abstract final class QuestDay {
  static const _yearFactor = 10000;
  static const _monthFactor = 100;

  static int keyOf(DateTime date) =>
      date.year * _yearFactor + date.month * _monthFactor + date.day;
}
