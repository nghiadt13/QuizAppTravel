import 'dart:typed_data';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../domain/entities/quiz_set.dart';
import '../../domain/repositories/i_quiz_manager_repository.dart';
import 'i_quiz_manager_service.dart';

class QuizManagerServiceImpl implements IQuizManagerService {
  final IQuizManagerRepository _repository;
  final CloudinaryService _cloudinary;

  QuizManagerServiceImpl(this._repository, this._cloudinary);

  @override
  Future<List<QuizSet>> getMyQuizzes(String userId) async {
    final trimmedId = userId.trim();
    if (trimmedId.isEmpty) {
      throw const AppException('User ID không được để trống.');
    }
    return _repository.getMyQuizzes(trimmedId);
  }

  @override
  Future<List<QuizSet>> getPublicQuizzes() async {
    return _repository.getPublicQuizzes();
  }

  @override
  Future<QuizSet?> getQuizById(String quizId) async {
    final trimmedId = quizId.trim();
    if (trimmedId.isEmpty) {
      throw const AppException('Quiz ID không được để trống.');
    }
    return _repository.getQuizById(trimmedId);
  }

  @override
  Future<void> saveQuiz(QuizSet quizSet) async {
    final title = quizSet.title.trim();
    final description = quizSet.description.trim();

    if (title.isEmpty) {
      throw const AppException('Tiêu đề bộ câu hỏi không được để trống.');
    }
    if (description.isEmpty) {
      throw const AppException('Mô tả bộ câu hỏi không được để trống.');
    }
    if (quizSet.questions.isEmpty) {
      throw const AppException('Bộ câu hỏi phải có ít nhất 1 câu hỏi.');
    }

    // Validate each question
    for (int i = 0; i < quizSet.questions.length; i++) {
      final q = quizSet.questions[i];
      final text = q.text.trim();
      if (text.isEmpty) {
        throw AppException('Câu hỏi thứ ${i + 1} không được để trống.');
      }
      if (q.options.length < 2) {
        throw AppException('Câu hỏi thứ ${i + 1} phải có ít nhất 2 đáp án lựa chọn.');
      }
      for (int o = 0; o < q.options.length; o++) {
        if (q.options[o].trim().isEmpty) {
          throw AppException('Đáp án thứ ${o + 1} của Câu hỏi ${i + 1} không được để trống.');
        }
      }
      if (q.correctIndex < 0 || q.correctIndex >= q.options.length) {
        throw AppException('Vui lòng chọn đáp án chính xác cho Câu hỏi ${i + 1}.');
      }
      if (q.timeLimit <= 0) {
        throw AppException('Thời gian trả lời Câu hỏi ${i + 1} phải lớn hơn 0 giây.');
      }
    }

    final validatedQuiz = quizSet.copyWith(
      title: title,
      description: description,
    );

    await _repository.createQuiz(validatedQuiz);
  }

  @override
  Future<void> deleteQuiz(String quizId) async {
    final trimmedId = quizId.trim();
    if (trimmedId.isEmpty) {
      throw const AppException('Quiz ID không được để trống.');
    }
    await _repository.deleteQuiz(trimmedId);
  }

  @override
  Future<String> uploadQuizCover(Uint8List imageBytes, String userId) async {
    if (userId.isEmpty) {
      throw const AppException('User ID không được để trống.');
    }

    try {
      return await _cloudinary.uploadImage(
        imageBytes: imageBytes,
        folder: 'quiz_covers',
        publicId: 'quiz_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      throw AppException('Không thể tải ảnh lên: $e');
    }
  }
}
