import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/participant_dto.dart';
import '../dtos/quest_room_dto.dart';

abstract interface class IQuestRoomRemoteDataSource {
  Future<QuestRoomDto> createRoom({
    required String topic,
    required String hostId,
    required bool isPublic,
    required String pinCode,
  });
  Future<QuestRoomDto?> findRoomByPin(String pinCode);
  Future<void> joinRoom(String roomId, ParticipantDto participant);
  Stream<List<ParticipantDto>> watchParticipants(String roomId);
  Stream<QuestRoomDto?> watchRoom(String roomId);
  Future<void> updateRoomStatus(String roomId, String status);
  Future<void> removeParticipant(String roomId, String playerId);
  Future<List<QuestRoomDto>> fetchActivePublicRooms();
}

class QuestRoomRemoteDataSourceImpl implements IQuestRoomRemoteDataSource {
  final FirebaseFirestore _firestore;

  QuestRoomRemoteDataSourceImpl(this._firestore);

  @override
  Future<QuestRoomDto> createRoom({
    required String topic,
    required String hostId,
    required bool isPublic,
    required String pinCode,
  }) async {
    try {
      final roomRef = _firestore.collection('rooms').doc();
      final roomDto = QuestRoomDto(
        id: roomRef.id,
        pinCode: pinCode,
        topic: topic,
        hostId: hostId,
        status: 'waiting',
        isPublic: isPublic,
        createdAt: DateTime.now(),
      );

      await roomRef.set(roomDto.toFirestore());
      return roomDto;
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to create room in Firestore.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<QuestRoomDto?> findRoomByPin(String pinCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('rooms')
          .where('pinCode', isEqualTo: pinCode)
          .where('status', isEqualTo: 'waiting')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      final doc = querySnapshot.docs.first;
      return QuestRoomDto.fromFirestore(doc.data(), doc.id);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to search room by PIN.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<void> joinRoom(String roomId, ParticipantDto participant) async {
    try {
      await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(participant.playerId)
          .set(participant.toFirestore());
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to join room.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Stream<List<ParticipantDto>> watchParticipants(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('participants')
        .orderBy('joinedAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ParticipantDto.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Stream<QuestRoomDto?> watchRoom(String roomId) {
    return _firestore.collection('rooms').doc(roomId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return QuestRoomDto.fromFirestore(doc.data()!, doc.id);
    });
  }

  @override
  Future<void> updateRoomStatus(String roomId, String status) async {
    try {
      await _firestore.collection('rooms').doc(roomId).update({
        'status': status,
      });
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to update room status.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<void> removeParticipant(String roomId, String playerId) async {
    try {
      await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(playerId)
          .delete();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to remove participant.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<List<QuestRoomDto>> fetchActivePublicRooms() async {
    try {
      final snapshot = await _firestore
          .collection('rooms')
          .where('isPublic', isEqualTo: true)
          .where('status', isEqualTo: 'waiting')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => QuestRoomDto.fromFirestore(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to fetch public quests.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
