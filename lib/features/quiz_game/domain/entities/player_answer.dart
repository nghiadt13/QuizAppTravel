class PlayerAnswer {
  final String questionId;
  final int selectedIndex;
  final int responseTimeMs;
  final bool isCorrect;
  final int pointsEarned;

  const PlayerAnswer({
    required this.questionId,
    required this.selectedIndex,
    required this.responseTimeMs,
    required this.isCorrect,
    required this.pointsEarned,
  });
}
