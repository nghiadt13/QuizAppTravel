enum PlayerGameStatus {
  playing,
  finished,
}

class PlayerLiveStatus {
  final String userId;
  final String displayName;
  final String? avatarId;
  final int currentQuestionIndex;
  final int totalQuestions;
  final int score;
  final PlayerGameStatus status;
  final DateTime? finishedAt;
  final int? rank;

  const PlayerLiveStatus({
    required this.userId,
    required this.displayName,
    this.avatarId,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.score,
    required this.status,
    this.finishedAt,
    this.rank,
  });
}
