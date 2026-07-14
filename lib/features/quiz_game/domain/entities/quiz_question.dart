class QuizQuestion {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String? imageUrl;
  final int timeLimit; // in seconds
  final String? hintText;

  const QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.imageUrl,
    this.timeLimit = 30,
    this.hintText,
  });
}
