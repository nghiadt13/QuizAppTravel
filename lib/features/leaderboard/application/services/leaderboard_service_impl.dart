import '../../domain/entities/leaderboard.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/i_leaderboard_repository.dart';
import 'i_leaderboard_service.dart';

class LeaderboardServiceImpl implements ILeaderboardService {
  final ILeaderboardRepository _repository;

  LeaderboardServiceImpl(this._repository);

  @override
  Future<Leaderboard> getLeaderboard(
    String period, {
    int limit = 20,
    String? lastUserId,
  }) async {
    return _repository.fetchLeaderboard(
      period,
      limit: limit,
      lastUserId: lastUserId,
    );
  }

  @override
  Future<LeaderboardEntry?> getUserRank(String period, String userId) async {
    return _repository.fetchUserRank(period, userId);
  }

  @override
  Stream<LeaderboardEntry?> watchUserRank(String period, String userId) {
    return _repository.watchUserRank(period, userId);
  }

  @override
  Future<void> submitGameScore(
    String period,
    String userId,
    int score, {
    required String displayName,
    String? avatarUrl,
  }) async {
    await _repository.updateScore(
      period,
      userId,
      score,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }
}
