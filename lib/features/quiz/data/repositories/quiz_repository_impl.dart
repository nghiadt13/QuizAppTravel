import 'package:quiz_app_travel/features/quiz/domain/entities/player.dart';
import 'package:quiz_app_travel/features/quiz/domain/entities/question.dart';
import 'package:quiz_app_travel/features/quiz/domain/repositories/i_quiz_repository.dart';
import 'package:quiz_app_travel/features/quiz/data/datasource/quiz_remote_data_source.dart';
import 'package:quiz_app_travel/features/quiz/data/dtos/player_dto.dart';

class QuizRepositoryImpl implements IQuizRepository {
  final QuizRemoteDataSource remoteDataSource;

  QuizRepositoryImpl(this.remoteDataSource);

  @override
  Future<Player> joinRoom(String pin, String name) async {
    final playerDto = await remoteDataSource.joinRoom(pin, name);
    return Player(name: playerDto.name, score: playerDto.score);
  }

  @override
  Future<List<Question>> getQuestions(String pin) async {
    final dtos = await remoteDataSource.fetchQuestions(pin);
    return dtos.map((dto) => Question(
      id: dto.id,
      content: dto.content,
      options: dto.options,
      correctAnswerIndex: dto.correctAnswerIndex,
    )).toList();
  }

  @override
  Future<void> submitScore(String pin, Player player) async {
    await remoteDataSource.submitScore(
      pin, 
      PlayerDto(name: player.name, score: player.score),
    );
  }

  @override
  Future<List<Player>> getLeaderboard(String pin) async {
    final dtos = await remoteDataSource.fetchLeaderboard(pin);
    return dtos.map((dto) => Player(name: dto.name, score: dto.score)).toList();
  }
}
