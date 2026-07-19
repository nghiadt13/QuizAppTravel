import '../../domain/entities/quiz_set.dart';

abstract interface class IQuizManagerService {
  Future<List<QuizSet>> getMyQuizzes(String userId);
  Future<List<QuizSet>> getPublicQuizzes();
  Future<QuizSet?> getQuizById(String quizId);
  Future<void> saveQuiz(QuizSet quizSet);
  Future<void> deleteQuiz(String quizId);
}
