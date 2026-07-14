enum ParticipantStatus {
  joined,
  playing,
  finished,
}

class Participant {
  final String playerId;
  final String displayName;
  final String avatarId;
  final ParticipantStatus status;
  final int score;
  final int currentQuestionIndex;
  final DateTime joinedAt;

  const Participant({
    required this.playerId,
    required this.displayName,
    required this.avatarId,
    required this.status,
    required this.score,
    required this.currentQuestionIndex,
    required this.joinedAt,
  });
}
