import '../../domain/entities/player_answer.dart';
import '../../domain/entities/quiz_question.dart';

abstract interface class IQuizService {
  Future<List<QuizQuestion>> loadQuestions(String roomId);
  
  PlayerAnswer processAnswer({
    required String questionId,
    required int selectedIndex,
    required int correctIndex,
    required int responseTimeMs,
    required int timeLimit,
  });

  Future<void> submitAnswer(String roomId, String userId, PlayerAnswer answer);
  Future<void> submitScore(String roomId, String userId, int totalScore);
}
