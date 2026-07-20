import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/constants/system_quiz_presets.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../quiz_game/domain/entities/quiz_question.dart';
import '../../domain/entities/quiz_set.dart';
import '../../application/services/i_quiz_manager_service.dart';

class QuizManagerViewModel extends ChangeNotifier {
  final IQuizManagerService _service;

  QuizManagerViewModel(this._service);

  List<QuizSet> _myQuizzes = [];
  List<QuizSet> get myQuizzes => _myQuizzes;

  List<QuizSet> _publicQuizzes = [];
  List<QuizSet> get publicQuizzes => _publicQuizzes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Form State for creating/editing quiz
  QuizSet? _editingQuiz;
  QuizSet? get editingQuiz => _editingQuiz;

  List<QuizQuestion> _editingQuestions = [];
  List<QuizQuestion> get editingQuestions => _editingQuestions;

  void startNewQuiz(String userId) {
    _editingQuiz = QuizSet(
      id: '',
      title: '',
      description: '',
      imageUrl: _getRandomTravelCover(),
      creatorId: userId,
      isPublic: true,
      createdAt: DateTime.now(),
      questions: const [],
    );
    // Initialize with 1 default blank question
    _editingQuestions = [
      const QuizQuestion(
        id: 'q_init_1',
        text: '',
        options: ['', '', '', ''],
        correctIndex: 0,
        timeLimit: 20,
      ),
    ];
    _errorMessage = null;
    notifyListeners();
  }

  void startEditingQuiz(QuizSet quiz) {
    _editingQuiz = quiz;
    _editingQuestions = List.from(quiz.questions);
    _errorMessage = null;
    notifyListeners();
  }

  void updateQuizDetails({
    required String title,
    required String description,
    required String? imageUrl,
    required bool isPublic,
  }) {
    if (_editingQuiz != null) {
      _editingQuiz = _editingQuiz!.copyWith(
        title: title,
        description: description,
        imageUrl: imageUrl,
        isPublic: isPublic,
      );
    }
  }

  void addQuestion() {
    _editingQuestions.add(
      QuizQuestion(
        id: 'q_new_${DateTime.now().millisecondsSinceEpoch}',
        text: '',
        options: const ['', '', '', ''],
        correctIndex: 0,
        timeLimit: 20,
      ),
    );
    notifyListeners();
  }

  void removeQuestion(int index) {
    if (_editingQuestions.length > 1) {
      _editingQuestions.removeAt(index);
      notifyListeners();
    }
  }

  void updateQuestionText(int index, String text) {
    final q = _editingQuestions[index];
    _editingQuestions[index] = QuizQuestion(
      id: q.id,
      text: text,
      options: q.options,
      correctIndex: q.correctIndex,
      imageUrl: q.imageUrl,
      timeLimit: q.timeLimit,
      hintText: q.hintText,
    );
  }

  void updateQuestionOption(
    int questionIndex,
    int optionIndex,
    String optionText,
  ) {
    final q = _editingQuestions[questionIndex];
    final newOptions = List<String>.from(q.options);
    newOptions[optionIndex] = optionText;

    _editingQuestions[questionIndex] = QuizQuestion(
      id: q.id,
      text: q.text,
      options: newOptions,
      correctIndex: q.correctIndex,
      imageUrl: q.imageUrl,
      timeLimit: q.timeLimit,
      hintText: q.hintText,
    );
  }

  void updateQuestionCorrectIndex(int questionIndex, int correctIndex) {
    final q = _editingQuestions[questionIndex];
    _editingQuestions[questionIndex] = QuizQuestion(
      id: q.id,
      text: q.text,
      options: q.options,
      correctIndex: correctIndex,
      imageUrl: q.imageUrl,
      timeLimit: q.timeLimit,
      hintText: q.hintText,
    );
    notifyListeners();
  }

  void updateQuestionTimeLimit(int questionIndex, int timeLimit) {
    final q = _editingQuestions[questionIndex];
    _editingQuestions[questionIndex] = QuizQuestion(
      id: q.id,
      text: q.text,
      options: q.options,
      correctIndex: q.correctIndex,
      imageUrl: q.imageUrl,
      timeLimit: timeLimit,
      hintText: q.hintText,
    );
    notifyListeners();
  }

  void updateQuestionHint(int index, String hint) {
    final q = _editingQuestions[index];
    _editingQuestions[index] = QuizQuestion(
      id: q.id,
      text: q.text,
      options: q.options,
      correctIndex: q.correctIndex,
      imageUrl: q.imageUrl,
      timeLimit: q.timeLimit,
      hintText: hint.trim().isEmpty ? null : hint,
    );
  }

  Future<bool> saveQuiz() async {
    if (_editingQuiz == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final quizToSave = _editingQuiz!.copyWith(questions: _editingQuestions);
      await _service.saveQuiz(quizToSave);

      // Reload my quizzes list
      if (quizToSave.creatorId != null) {
        await fetchMyQuizzes(quizToSave.creatorId!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi không xác định khi lưu bộ câu hỏi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMyQuizzes(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myQuizzes = await _service.getMyQuizzes(userId);
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Lỗi khi tải danh sách bộ câu hỏi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPublicQuizzes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final remoteQuizzes = await _service.getPublicQuizzes();
      _publicQuizzes = _mergeWithSystemQuizzes(remoteQuizzes);
    } on AppException catch (e) {
      _errorMessage = e.message;
      _publicQuizzes = SystemQuizPresets.quizzes;
    } catch (e) {
      _errorMessage = 'Lỗi khi tải danh sách bộ câu hỏi công khai.';
      _publicQuizzes = SystemQuizPresets.quizzes;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteQuiz(String quizId, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteQuiz(quizId);
      await fetchMyQuizzes(userId);
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Lỗi khi xóa bộ câu hỏi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getRandomTravelCover() {
    final covers = [
      'https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=600&q=80', // Hạ Long
      'https://images.unsplash.com/photo-1509060464153-44667396260f?auto=format&fit=crop&w=600&q=80', // Sapa
      'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=600&q=80', // Food
      'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=600&q=80', // Travel boat
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80', // Beach
    ];
    return covers[DateTime.now().millisecond % covers.length];
  }

  List<QuizSet> _mergeWithSystemQuizzes(List<QuizSet> remoteQuizzes) {
    final merged = <QuizSet>[...SystemQuizPresets.quizzes];
    for (final quiz in remoteQuizzes) {
      final exists = merged.any((systemQuiz) => systemQuiz.id == quiz.id);
      if (!exists) {
        merged.add(quiz);
      }
    }
    return merged;
  }

  Future<String?> uploadQuizCover(Uint8List imageBytes, String userId) async {
    try {
      final downloadUrl = await _service.uploadQuizCover(imageBytes, userId);
      return downloadUrl;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Không thể tải ảnh lên.';
      notifyListeners();
      return null;
    }
  }
}
