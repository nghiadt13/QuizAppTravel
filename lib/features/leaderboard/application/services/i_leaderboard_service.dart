import '../../domain/entities/leaderboard.dart';
import '../../domain/entities/leaderboard_entry.dart';

abstract interface class ILeaderboardService {
  Future<Leaderboard> getLeaderboard(
    String period, {
    int limit = 20,
    String? lastUserId,
  });
  Future<LeaderboardEntry?> getUserRank(String period, String userId);
  Stream<LeaderboardEntry?> watchUserRank(String period, String userId);
  Future<void> submitGameScore(String period, String userId, int score);
}
