import '../../domain/entities/preset_avatar.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/quest_room.dart';

abstract interface class IQuestRoomService {
  Future<QuestRoom> createRoom({
    required String topic,
    required String hostId,
    required bool isPublic,
  });
  Future<QuestRoom> joinRoom({
    required String pinCode,
    required String displayName,
    required String avatarId,
    required String playerId,
  });
  Stream<List<Participant>> watchParticipants(String roomId);
  Stream<QuestRoom?> watchRoom(String roomId);
  Future<void> startQuest(String roomId);
  Future<void> leaveRoom(String roomId, String playerId);
  Future<List<PresetAvatar>> getPresetAvatars();
  Future<List<QuestRoom>> getActivePublicRooms();
}
