import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/player_live_status_dto.dart';

abstract interface class IMonitoringRemoteDataSource {
  Stream<List<PlayerLiveStatusDto>> watchPlayerStatuses(String roomId);
  Stream<String> watchRoomStatus(String roomId);
  Future<void> pauseGame(String roomId);
  Future<void> resumeGame(String roomId);
  Future<void> endGame(String roomId);
}

class MonitoringRemoteDataSourceImpl implements IMonitoringRemoteDataSource {
  final FirebaseFirestore _firestore;

  MonitoringRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<PlayerLiveStatusDto>> watchPlayerStatuses(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('participants')
        .orderBy('score', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PlayerLiveStatusDto.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Stream<String> watchRoomStatus(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .map((doc) => doc.data()?['status'] ?? 'waiting');
  }

  @override
  Future<void> pauseGame(String roomId) async {
    try {
      await _firestore.collection('rooms').doc(roomId).update({
        'status': 'paused',
        'pausedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to pause game.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<void> resumeGame(String roomId) async {
    try {
      await _firestore.collection('rooms').doc(roomId).update({
        'status': 'playing',
      });
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to resume game.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<void> endGame(String roomId) async {
    try {
      await _firestore.collection('rooms').doc(roomId).update({
        'status': 'finished',
        'finishedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to end game.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
