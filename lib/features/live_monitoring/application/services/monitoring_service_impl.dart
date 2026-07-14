import '../../domain/entities/player_live_status.dart';
import '../../domain/repositories/i_monitoring_repository.dart';
import 'i_monitoring_service.dart';

class MonitoringServiceImpl implements IMonitoringService {
  final IMonitoringRepository _repository;

  MonitoringServiceImpl(this._repository);

  @override
  Stream<List<PlayerLiveStatus>> watchPlayerStatuses(String roomId, int totalQuestions) {
    return _repository.watchPlayerStatuses(roomId, totalQuestions);
  }

  @override
  Stream<String> watchRoomStatus(String roomId) {
    return _repository.watchRoomStatus(roomId);
  }

  @override
  Future<void> pauseGame(String roomId) async {
    await _repository.pauseGame(roomId);
  }

  @override
  Future<void> resumeGame(String roomId) async {
    await _repository.resumeGame(roomId);
  }

  @override
  Future<void> endGame(String roomId) async {
    await _repository.endGame(roomId);
  }
}
