import 'package:quiz_app_travel/features/quiz/domain/entities/player.dart';
import 'package:quiz_app_travel/features/quiz/domain/entities/question.dart';
import 'package:quiz_app_travel/features/quiz/domain/repositories/i_quiz_repository.dart';
import 'package:quiz_app_travel/features/quiz/application/services/i_quiz_service.dart';

class QuizService implements IQuizService {
  final IQuizRepository _repository;

  QuizService(this._repository);

  @override
  Future<Player> joinRoom(String pin, String name) async {
    if (pin.isEmpty || name.isEmpty) {
      throw Exception('PIN and Name cannot be empty');
    }
    return _repository.joinRoom(pin, name);
  }

  @override
  Future<List<Question>> getQuestions(String pin) {
    return _repository.getQuestions(pin);
  }

  @override
  Future<void> submitScore(String pin, Player player) {
    return _repository.submitScore(pin, player);
  }

  @override
  Future<List<Player>> getLeaderboard(String pin) {
    return _repository.getLeaderboard(pin);
  }
}
