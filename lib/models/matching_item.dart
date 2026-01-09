/// A matching exercise item that pairs an image with a word.
class MatchingItem {
  final String id;
  final String imagePath;
  final String correctWord;
  final String title; // Spanish name for context

  const MatchingItem({
    required this.id,
    required this.imagePath,
    required this.correctWord,
    required this.title,
  });

  @override
  String toString() => 'MatchingItem($id, $correctWord)';
}
