import '../entities/player_answer.dart';
import '../entities/quiz_question.dart';

abstract interface class IQuizRepository {
  Future<List<QuizQuestion>> fetchQuestions(String roomId);
  Future<void> submitAnswer(String roomId, String userId, PlayerAnswer answer);
  Future<void> updateScore(String roomId, String userId, int totalScore);
}
