import '../../domain/entities/player_live_status.dart';
import '../../domain/repositories/i_monitoring_repository.dart';
import '../datasources/monitoring_remote_data_source.dart';
import '../mappers/player_live_status_mapper.dart';

class MonitoringRepositoryImpl implements IMonitoringRepository {
  final IMonitoringRemoteDataSource _remoteDataSource;
  final PlayerLiveStatusMapper _mapper;

  MonitoringRepositoryImpl(this._remoteDataSource, this._mapper);

  @override
  Stream<List<PlayerLiveStatus>> watchPlayerStatuses(String roomId, int totalQuestions) {
    return _remoteDataSource.watchPlayerStatuses(roomId).map((list) {
      return list.map((dto) => _mapper.map(dto, totalQuestions)).toList();
    });
  }

  @override
  Stream<String> watchRoomStatus(String roomId) {
    return _remoteDataSource.watchRoomStatus(roomId);
  }

  @override
  Future<void> pauseGame(String roomId) async {
    await _remoteDataSource.pauseGame(roomId);
  }

  @override
  Future<void> resumeGame(String roomId) async {
    await _remoteDataSource.resumeGame(roomId);
  }

  @override
  Future<void> endGame(String roomId) async {
    await _remoteDataSource.endGame(roomId);
  }
}
