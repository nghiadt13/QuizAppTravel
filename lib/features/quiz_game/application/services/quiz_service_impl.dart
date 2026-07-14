import 'dart:math';
import '../../domain/entities/player_answer.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/repositories/i_quiz_repository.dart';
import 'i_quiz_service.dart';

class QuizServiceImpl implements IQuizService {
  final IQuizRepository _repository;

  QuizServiceImpl(this._repository);

  @override
  Future<List<QuizQuestion>> loadQuestions(String roomId) async {
    return _repository.fetchQuestions(roomId);
  }

  @override
  PlayerAnswer processAnswer({
    required String questionId,
    required int selectedIndex,
    required int correctIndex,
    required int responseTimeMs,
    required int timeLimit,
  }) {
    final isCorrect = selectedIndex == correctIndex;
    int pointsEarned = 0;

    if (isCorrect) {
      // Check if answered within first 50% of the time limit (fast bonus)
      final halfTimeMs = (timeLimit * 1000) / 2;
      if (responseTimeMs <= halfTimeMs) {
        pointsEarned = 200; // Fast bonus
      } else {
        pointsEarned = 150; // Normal correct
      }
    }

    return PlayerAnswer(
      questionId: questionId,
      selectedIndex: selectedIndex,
      responseTimeMs: responseTimeMs,
      isCorrect: isCorrect,
      pointsEarned: pointsEarned,
    );
  }

  @override
  Future<void> submitAnswer(String roomId, String userId, PlayerAnswer answer) async {
    await _repository.submitAnswer(roomId, userId, answer);
  }

  @override
  Future<void> submitScore(String roomId, String userId, int totalScore) async {
    await _repository.updateScore(roomId, userId, max(0, totalScore));
  }
}
