import '../../../../core/mappers/mapper.dart';
import '../../domain/entities/participant.dart';
import '../dtos/participant_dto.dart';

class ParticipantMapper implements IMapper<ParticipantDto, Participant> {
  @override
  Participant map(ParticipantDto source) {
    ParticipantStatus participantStatus;
    switch (source.status) {
      case 'playing':
        participantStatus = ParticipantStatus.playing;
        break;
      case 'finished':
        participantStatus = ParticipantStatus.finished;
        break;
      case 'joined':
      default:
        participantStatus = ParticipantStatus.joined;
        break;
    }

    return Participant(
      playerId: source.playerId,
      displayName: source.displayName,
      avatarId: source.avatarId,
      status: participantStatus,
      score: source.score,
      currentQuestionIndex: source.currentQuestionIndex,
      joinedAt: source.joinedAt,
    );
  }
}
