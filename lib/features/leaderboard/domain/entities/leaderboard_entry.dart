class LeaderboardEntry {
  final int rank;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int totalScore;
  final int gamesPlayed;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.totalScore,
    required this.gamesPlayed,
  });
}
