import 'dart:math';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/preset_avatar.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/quest_room.dart';
import '../../domain/repositories/i_quest_room_repository.dart';
import 'i_quest_room_service.dart';

class QuestRoomServiceImpl implements IQuestRoomService {
  final IQuestRoomRepository _repository;

  QuestRoomServiceImpl(this._repository);

  @override
  Future<QuestRoom> createRoom({
    required String topic,
    required String hostId,
    required bool isPublic,
    String? quizId,
  }) async {
    final cleanTopic = topic.trim();
    if (cleanTopic.isEmpty) {
      throw const AppException('Quest topic cannot be empty.');
    }

    // Generate unique 6-digit PIN
    String pinCode = '';
    bool isUnique = false;
    int retries = 0;

    while (!isUnique && retries < 5) {
      pinCode = _generateRandomPin();
      final existingRoom = await _repository.findRoomByPin(pinCode);
      if (existingRoom == null) {
        isUnique = true;
      }
      retries++;
    }

    if (!isUnique) {
      throw const AppException('Failed to generate a unique room PIN. Please try again.');
    }

    return _repository.createRoom(
      topic: cleanTopic,
      hostId: hostId,
      isPublic: isPublic,
      pinCode: pinCode,
      quizId: quizId,
    );
  }

  @override
  Future<QuestRoom> joinRoom({
    required String pinCode,
    required String displayName,
    required String avatarId,
    required String playerId,
  }) async {
    final cleanPin = pinCode.trim();
    final cleanName = displayName.trim();

    if (cleanPin.length != 6) {
      throw const AppException('PIN code must be 6 digits.');
    }
    if (cleanName.isEmpty) {
      throw const AppException('Name cannot be empty.');
    }

    var room = await _repository.findRoomByPin(cleanPin);
    if (room == null) {
      final strippedPin = cleanPin.replaceFirst(RegExp(r'^0+'), '');
      if (strippedPin.isNotEmpty && strippedPin != cleanPin) {
        room = await _repository.findRoomByPin(strippedPin);
      }
    }
    if (room == null) {
      throw const AppException('Quest room not found or has already started.', code: 'NOT_FOUND');
    }

    if (room.status != RoomStatus.waiting) {
      throw const AppException('This quest room is no longer in lobby state.', code: 'INVALID_STATUS');
    }

    final participant = Participant(
      playerId: playerId,
      displayName: cleanName,
      avatarId: avatarId,
      status: ParticipantStatus.joined,
      score: 0,
      currentQuestionIndex: 0,
      joinedAt: DateTime.now(),
    );

    await _repository.joinRoom(room.id, participant);
    return room;
  }

  @override
  Stream<List<Participant>> watchParticipants(String roomId) {
    return _repository.watchParticipants(roomId);
  }

  @override
  Stream<QuestRoom?> watchRoom(String roomId) {
    return _repository.watchRoom(roomId);
  }

  @override
  Future<void> startQuest(String roomId) async {
    await _repository.updateRoomStatus(roomId, RoomStatus.playing);
  }

  @override
  Future<void> leaveRoom(String roomId, String playerId) async {
    await _repository.removeParticipant(roomId, playerId);
  }

  @override
  Future<List<PresetAvatar>> getPresetAvatars() async {
    return _repository.fetchPresetAvatars();
  }

  @override
  Future<List<QuestRoom>> getActivePublicRooms() async {
    return _repository.fetchActivePublicRooms();
  }

  @override
  Future<List<QuestRoom>> getRoomsByHost(String hostId) async {
    final trimmedId = hostId.trim();
    if (trimmedId.isEmpty) {
      throw const AppException('Host ID cannot be empty.');
    }
    return _repository.getRoomsByHost(trimmedId);
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    final trimmedId = roomId.trim();
    if (trimmedId.isEmpty) {
      throw const AppException('Room ID cannot be empty.');
    }
    await _repository.deleteRoom(trimmedId);
  }

  String _generateRandomPin() {
    final random = Random();
    final buffer = StringBuffer();
    for (int i = 0; i < 6; i++) {
      buffer.write(random.nextInt(10));
    }
    return buffer.toString();
  }
}
