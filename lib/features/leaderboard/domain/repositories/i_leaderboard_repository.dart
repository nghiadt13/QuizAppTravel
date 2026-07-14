import '../entities/leaderboard.dart';
import '../entities/leaderboard_entry.dart';

abstract interface class ILeaderboardRepository {
  Future<Leaderboard> fetchLeaderboard(
    String period, {
    int limit = 20,
    String? lastUserId,
  });
  Future<LeaderboardEntry?> fetchUserRank(String period, String userId);
  Stream<LeaderboardEntry?> watchUserRank(String period, String userId);
  Future<void> updateScore(String period, String userId, int scoreChange);
}
