import '../../../../core/mappers/mapper.dart';
import '../../domain/entities/quest_room.dart';
import '../dtos/quest_room_dto.dart';

class QuestRoomMapper implements IMapper<QuestRoomDto, QuestRoom> {
  @override
  QuestRoom map(QuestRoomDto source) {
    RoomStatus roomStatus;
    switch (source.status) {
      case 'playing':
        roomStatus = RoomStatus.playing;
        break;
      case 'finished':
        roomStatus = RoomStatus.finished;
        break;
      case 'waiting':
      default:
        roomStatus = RoomStatus.waiting;
        break;
    }

    return QuestRoom(
      id: source.id,
      pinCode: source.pinCode,
      topic: source.topic,
      hostId: source.hostId,
      status: roomStatus,
      isPublic: source.isPublic,
      createdAt: source.createdAt,
      quizId: source.quizId,
    );
  }
}
