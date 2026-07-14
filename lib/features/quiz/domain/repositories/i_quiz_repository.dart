import 'package:quiz_app_travel/features/quiz/domain/entities/player.dart';
import 'package:quiz_app_travel/features/quiz/domain/entities/question.dart';

abstract class IQuizRepository {
  Future<Player> joinRoom(String pin, String name);
  Future<List<Question>> getQuestions(String pin);
  Future<void> submitScore(String pin, Player player);
  Future<List<Player>> getLeaderboard(String pin);
}
