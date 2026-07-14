import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/player_answer.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/repositories/i_quiz_repository.dart';
import '../datasources/quiz_remote_data_source.dart';
import '../mappers/quiz_question_mapper.dart';

class QuizRepositoryImpl implements IQuizRepository {
  final IQuizRemoteDataSource _remoteDataSource;
  final QuizQuestionMapper _mapper;

  QuizRepositoryImpl(this._remoteDataSource, this._mapper);

  @override
  Future<List<QuizQuestion>> fetchQuestions(String roomId) async {
    final list = await _remoteDataSource.fetchQuestions(roomId);
    return list.map((dto) => _mapper.map(dto)).toList();
  }

  @override
  Future<void> submitAnswer(String roomId, String userId, PlayerAnswer answer) async {
    final data = {
      'selectedIndex': answer.selectedIndex,
      'responseTimeMs': answer.responseTimeMs,
      'isCorrect': answer.isCorrect,
      'pointsEarned': answer.pointsEarned,
      'submittedAt': FieldValue.serverTimestamp(),
    };
    await _remoteDataSource.submitAnswer(roomId, userId, answer.questionId, data);
  }

  @override
  Future<void> updateScore(String roomId, String userId, int totalScore) async {
    await _remoteDataSource.updateScore(roomId, userId, totalScore);
  }
}
