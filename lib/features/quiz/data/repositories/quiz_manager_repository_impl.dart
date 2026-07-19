import '../../domain/entities/quiz_set.dart';
import '../../domain/repositories/i_quiz_manager_repository.dart';
import '../datasources/quiz_manager_remote_data_source.dart';
import '../mappers/quiz_mapper.dart';

class QuizManagerRepositoryImpl implements IQuizManagerRepository {
  final IQuizManagerRemoteDataSource _remoteDataSource;
  final QuizMapper _mapper;

  QuizManagerRepositoryImpl(this._remoteDataSource, this._mapper);

  @override
  Future<List<QuizSet>> getMyQuizzes(String userId) async {
    final dtos = await _remoteDataSource.fetchMyQuizzes(userId);
    final List<QuizSet> quizSets = [];
    for (final dto in dtos) {
      final questions = await _remoteDataSource.fetchQuizQuestions(dto.id);
      final mappedQuestions = questions.map((q) => _mapper.mapQuestionDtoToEntity(q)).toList();
      quizSets.add(_mapper.map(dto).copyWith(questions: mappedQuestions));
    }
    return quizSets;
  }

  @override
  Future<List<QuizSet>> getPublicQuizzes() async {
    final dtos = await _remoteDataSource.fetchPublicQuizzes();
    final List<QuizSet> quizSets = [];
    for (final dto in dtos) {
      final questions = await _remoteDataSource.fetchQuizQuestions(dto.id);
      final mappedQuestions = questions.map((q) => _mapper.mapQuestionDtoToEntity(q)).toList();
      quizSets.add(_mapper.map(dto).copyWith(questions: mappedQuestions));
    }
    return quizSets;
  }

  @override
  Future<QuizSet?> getQuizById(String quizId) async {
    final dto = await _remoteDataSource.fetchQuizById(quizId);
    if (dto == null) return null;
    final questions = await _remoteDataSource.fetchQuizQuestions(quizId);
    final mappedQuestions = questions.map((q) => _mapper.mapQuestionDtoToEntity(q)).toList();
    return _mapper.map(dto).copyWith(questions: mappedQuestions);
  }

  @override
  Future<void> createQuiz(QuizSet quizSet) async {
    final quizDto = _mapper.toDto(quizSet);
    final questionDtos = quizSet.questions.map((q) => _mapper.mapQuestionEntityToDto(q)).toList();
    await _remoteDataSource.createQuiz(quizDto, questionDtos);
  }

  @override
  Future<void> deleteQuiz(String quizId) async {
    await _remoteDataSource.deleteQuiz(quizId);
  }
}
