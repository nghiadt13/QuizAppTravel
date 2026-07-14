import '../../domain/entities/preset_avatar.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/quest_room.dart';
import '../../domain/repositories/i_quest_room_repository.dart';
import '../datasources/preset_avatar_data_source.dart';
import '../datasources/quest_room_remote_data_source.dart';
import '../dtos/participant_dto.dart';
import '../mappers/participant_mapper.dart';
import '../mappers/preset_avatar_mapper.dart';
import '../mappers/quest_room_mapper.dart';

class QuestRoomRepositoryImpl implements IQuestRoomRepository {
  final IQuestRoomRemoteDataSource _remoteDataSource;
  final IPresetAvatarDataSource _avatarDataSource;
  final QuestRoomMapper _roomMapper;
  final ParticipantMapper _participantMapper;
  final PresetAvatarMapper _avatarMapper;

  QuestRoomRepositoryImpl(
    this._remoteDataSource,
    this._avatarDataSource,
    this._roomMapper,
    this._participantMapper,
    this._avatarMapper,
  );

  @override
  Future<QuestRoom> createRoom({
    required String topic,
    required String hostId,
    required bool isPublic,
    required String pinCode,
  }) async {
    final dto = await _remoteDataSource.createRoom(
      topic: topic,
      hostId: hostId,
      isPublic: isPublic,
      pinCode: pinCode,
    );
    return _roomMapper.map(dto);
  }

  @override
  Future<QuestRoom?> findRoomByPin(String pinCode) async {
    final dto = await _remoteDataSource.findRoomByPin(pinCode);
    if (dto == null) return null;
    return _roomMapper.map(dto);
  }

  @override
  Future<void> joinRoom(String roomId, Participant participant) async {
    final dto = ParticipantDto(
      playerId: participant.playerId,
      displayName: participant.displayName,
      avatarId: participant.avatarId,
      status: participant.status.name,
      score: participant.score,
      currentQuestionIndex: participant.currentQuestionIndex,
      joinedAt: participant.joinedAt,
    );
    await _remoteDataSource.joinRoom(roomId, dto);
  }

  @override
  Stream<List<Participant>> watchParticipants(String roomId) {
    return _remoteDataSource.watchParticipants(roomId).map((list) {
      return list.map((dto) => _participantMapper.map(dto)).toList();
    });
  }

  @override
  Stream<QuestRoom?> watchRoom(String roomId) {
    return _remoteDataSource.watchRoom(roomId).map((dto) {
      if (dto == null) return null;
      return _roomMapper.map(dto);
    });
  }

  @override
  Future<void> updateRoomStatus(String roomId, RoomStatus status) async {
    await _remoteDataSource.updateRoomStatus(roomId, status.name);
  }

  @override
  Future<void> removeParticipant(String roomId, String playerId) async {
    await _remoteDataSource.removeParticipant(roomId, playerId);
  }

  @override
  Future<List<PresetAvatar>> fetchPresetAvatars() async {
    final list = await _avatarDataSource.fetchPresetAvatars();
    return list.map((dto) => _avatarMapper.map(dto)).toList();
  }

  @override
  Future<List<QuestRoom>> fetchActivePublicRooms() async {
    final list = await _remoteDataSource.fetchActivePublicRooms();
    return list.map((dto) => _roomMapper.map(dto)).toList();
  }
}
