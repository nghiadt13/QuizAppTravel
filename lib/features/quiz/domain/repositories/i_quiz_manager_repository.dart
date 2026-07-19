import '../entities/quiz_set.dart';

abstract interface class IQuizManagerRepository {
  Future<List<QuizSet>> getMyQuizzes(String userId);
  Future<List<QuizSet>> getPublicQuizzes();
  Future<QuizSet?> getQuizById(String quizId);
  Future<void> createQuiz(QuizSet quizSet);
  Future<void> deleteQuiz(String quizId);
}
