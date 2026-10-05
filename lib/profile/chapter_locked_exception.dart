class ChapterLockedException implements Exception {
  const ChapterLockedException(this.chapterNumber);

  final int chapterNumber;

  @override
  String toString() => 'ChapterLockedException: chapitre $chapterNumber';
}
