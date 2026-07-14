import '../../domain/entities/leaderboard_entry.dart';
import '../dtos/leaderboard_entry_dto.dart';

class LeaderboardEntryMapper {
  LeaderboardEntry map(LeaderboardEntryDto source, int rank) {
    return LeaderboardEntry(
      rank: rank,
      userId: source.userId,
      displayName: source.displayName,
      avatarUrl: source.avatarUrl,
      totalScore: source.totalScore,
      gamesPlayed: source.gamesPlayed,
    );
  }
}
