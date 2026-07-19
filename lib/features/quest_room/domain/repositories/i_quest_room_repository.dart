import '../entities/quest_room.dart';
import '../entities/participant.dart';
import '../entities/preset_avatar.dart';

abstract interface class IQuestRoomRepository {
  Future<QuestRoom> createRoom({
    required String topic,
    required String hostId,
    required bool isPublic,
    required String pinCode,
  });
  Future<QuestRoom?> findRoomByPin(String pinCode);
  Future<void> joinRoom(String roomId, Participant participant);
  Stream<List<Participant>> watchParticipants(String roomId);
  Stream<QuestRoom?> watchRoom(String roomId);
  Future<void> updateRoomStatus(String roomId, RoomStatus status);
  Future<void> removeParticipant(String roomId, String playerId);
  Future<List<PresetAvatar>> fetchPresetAvatars();
  Future<List<QuestRoom>> fetchActivePublicRooms();
  Future<List<QuestRoom>> getRoomsByHost(String hostId);
}
