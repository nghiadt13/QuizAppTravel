class Question {
  final int id;
  final String content;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.id,
    required this.content,
    required this.options,
    required this.correctAnswerIndex,
  });
}
