import '../../domain/entities/leaderboard.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/i_leaderboard_repository.dart';
import '../datasources/leaderboard_remote_data_source.dart';
import '../mappers/leaderboard_entry_mapper.dart';

class LeaderboardRepositoryImpl implements ILeaderboardRepository {
  final ILeaderboardRemoteDataSource _remoteDataSource;
  final LeaderboardEntryMapper _entryMapper;

  LeaderboardRepositoryImpl(this._remoteDataSource, this._entryMapper);

  @override
  Future<Leaderboard> fetchLeaderboard(
    String period, {
    int limit = 20,
    String? lastUserId,
  }) async {
    final list = await _remoteDataSource.fetchEntries(period, limit: limit, lastUserId: lastUserId);
    final metadata = await _remoteDataSource.fetchPeriodMetadata(period);

    final entries = <LeaderboardEntry>[];
    for (int i = 0; i < list.length; i++) {
      entries.add(_entryMapper.map(list[i], i + 1));
    }

    return Leaderboard(
      period: period,
      entries: entries,
      seasonEndDate: metadata.seasonEndDate,
      rewardDescription: metadata.rewardDescription,
      hasMore: list.length >= limit,
    );
  }

  @override
  Future<LeaderboardEntry?> fetchUserRank(String period, String userId) async {
    final dto = await _remoteDataSource.fetchUserRank(period, userId);
    if (dto == null) return null;

    final rank = await _remoteDataSource.fetchRankForScore(period, dto.totalScore);
    return _entryMapper.map(dto, rank);
  }

  @override
  Stream<LeaderboardEntry?> watchUserRank(String period, String userId) {
    return _remoteDataSource.watchUserRank(period, userId).asyncMap((dto) async {
      if (dto == null) return null;
      final rank = await _remoteDataSource.fetchRankForScore(period, dto.totalScore);
      return _entryMapper.map(dto, rank);
    });
  }

  @override
  Future<void> updateScore(String period, String userId, int scoreChange) async {
    await _remoteDataSource.updateScore(period, userId, scoreChange);
  }
}
