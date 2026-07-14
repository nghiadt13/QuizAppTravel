import '../entities/player_live_status.dart';

abstract interface class IMonitoringRepository {
  Stream<List<PlayerLiveStatus>> watchPlayerStatuses(String roomId, int totalQuestions);
  Stream<String> watchRoomStatus(String roomId);
  Future<void> pauseGame(String roomId);
  Future<void> resumeGame(String roomId);
  Future<void> endGame(String roomId);
}
