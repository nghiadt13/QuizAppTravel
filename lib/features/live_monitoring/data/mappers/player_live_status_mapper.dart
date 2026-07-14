import '../../domain/entities/player_live_status.dart';
import '../dtos/player_live_status_dto.dart';

class PlayerLiveStatusMapper {
  PlayerLiveStatus map(PlayerLiveStatusDto source, int totalQuestions) {
    final gameStatus = source.status == 'finished'
        ? PlayerGameStatus.finished
        : PlayerGameStatus.playing;

    return PlayerLiveStatus(
      userId: source.userId,
      displayName: source.displayName,
      avatarId: source.avatarId,
      currentQuestionIndex: source.currentQuestionIndex,
      totalQuestions: totalQuestions,
      score: source.score,
      status: gameStatus,
      finishedAt: source.finishedAt,
      rank: source.rank,
    );
  }
}
