import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/player_answer.dart';
import '../../domain/entities/quiz_question.dart';
import '../../application/services/i_quiz_service.dart';

class QuizPlayViewModel extends ChangeNotifier {
  final IQuizService _service;

  QuizPlayViewModel(this._service);

  List<QuizQuestion> _questions = [];
  List<QuizQuestion> get questions => _questions;

  int _currentQuestionIndex = 0;
  int get currentQuestionIndex => _currentQuestionIndex;

  int _score = 0;
  int get score => _score;

  int _correctAnswersCount = 0;
  int get correctAnswersCount => _correctAnswersCount;

  int _incorrectAnswersCount = 0;
  int get incorrectAnswersCount => _incorrectAnswersCount;

  int _timeRemaining = 0;
  int get timeRemaining => _timeRemaining;

  int? _selectedAnswerIndex;
  int? get selectedAnswerIndex => _selectedAnswerIndex;

  bool _isAnswered = false;
  bool get isAnswered => _isAnswered;

  String? _feedbackMessage;
  String? get feedbackMessage => _feedbackMessage;

  bool _hintUsed = false;
  bool get hintUsed => _hintUsed;

  List<int> _eliminatedAnswerIndices = [];
  List<int> get eliminatedAnswerIndices => _eliminatedAnswerIndices;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isFinished = false;
  bool get isFinished => _isFinished;

  String _roomTopic = '';
  String get roomTopic => _roomTopic;

  String? _quizId;
  String? get quizId => _quizId;

  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();

  QuizQuestion? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex];
  }

  Future<void> loadQuestions(String roomId) async {
    _isLoading = true;
    _errorMessage = null;
    _isFinished = false;
    _currentQuestionIndex = 0;
    _score = 0;
    _correctAnswersCount = 0;
    _incorrectAnswersCount = 0;
    _selectedAnswerIndex = null;
    _isAnswered = false;
    _feedbackMessage = null;
    _hintUsed = false;
    _eliminatedAnswerIndices = [];
    notifyListeners();

    try {
      try {
        final roomDoc = await FirebaseFirestore.instance.collection('rooms').doc(roomId).get();
        if (roomDoc.exists) {
          final data = roomDoc.data();
          _roomTopic = data?['topic'] as String? ?? '';
          _quizId = data?['quizId'] as String? ?? '';
        }
      } catch (_) {}

      _questions = await _service.loadQuestions(roomId);
      if (_questions.isNotEmpty) {
        startTimer();
      } else {
        _errorMessage = 'No questions available for this quest.';
      }
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load quiz. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startTimer() {
    _timer?.cancel();
    final question = currentQuestion;
    if (question == null) return;

    _timeRemaining = question.timeLimit;
    _stopwatch.reset();
    _stopwatch.start();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        // Time out: auto submit answer index 0 but marked as incorrect/timeout
        _handleTimeout();
      }
    });
  }

  Future<void> _handleTimeout() async {
    if (_isAnswered) return;
    _timer?.cancel();
    _stopwatch.stop();
    _incorrectAnswersCount++;

    final question = currentQuestion;
    if (question != null && _roomId.isNotEmpty && _userId.isNotEmpty) {
      final answer = PlayerAnswer(
        questionId: question.id,
        selectedIndex: -1,
        responseTimeMs: question.timeLimit * 1000,
        isCorrect: false,
        pointsEarned: 0,
      );

      try {
        await _service.submitAnswer(_roomId, _userId, answer);
        await _service.submitScore(_roomId, _userId, _score);
      } catch (_) {}
    }

    nextQuestion();
  }

  // To support firestore submission, let's keep track of roomId and userId in the viewmodel
  String _roomId = '';
  String _userId = '';

  void setRoomAndUser(String roomId, String userId) {
    _roomId = roomId;
    _userId = userId;
  }

  Future<void> selectAnswer(int index, String roomId, String userId) async {
    if (_isAnswered) return;
    _timer?.cancel();
    _stopwatch.stop();
    _isAnswered = true;
    _selectedAnswerIndex = index;
    _roomId = roomId;
    _userId = userId;
    notifyListeners();

    final question = currentQuestion;
    if (question == null) return;

    final responseTimeMs = _stopwatch.elapsedMilliseconds;
    
    // Process answer using service
    var answer = _service.processAnswer(
      questionId: question.id,
      selectedIndex: index,
      correctIndex: question.correctIndex,
      responseTimeMs: responseTimeMs,
      timeLimit: question.timeLimit,
    );

    if (answer.isCorrect) {
      _correctAnswersCount++;
      if (answer.pointsEarned == 200) {
        _feedbackMessage = '+200 Fast Bonus! ⚡';
      } else {
        _feedbackMessage = '+150 Correct! 🎉';
      }
    } else {
      _incorrectAnswersCount++;
      _feedbackMessage = 'Incorrect! 😢';
    }

    _score += answer.pointsEarned;

    try {
      await _service.submitAnswer(roomId, userId, answer);
      await _service.submitScore(roomId, userId, _score);
    } catch (_) {
      // Background operation failure shouldn't block gameplay
    }
    notifyListeners();
  }

  Future<void> useHint() async {
    if (_isAnswered || _hintUsed || currentQuestion == null) return;
    _hintUsed = true;
    
    // Eliminate 2 incorrect answers
    final question = currentQuestion!;
    final correctIndex = question.correctIndex;
    final optionsCount = question.options.length;

    // Get all incorrect indices
    List<int> incorrectIndices = [];
    for (int i = 0; i < optionsCount; i++) {
      if (i != correctIndex) {
        incorrectIndices.add(i);
      }
    }

    // Shuffle and pick 2 to eliminate
    incorrectIndices.shuffle();
    _eliminatedAnswerIndices = incorrectIndices.take(2).toList();

    // Deduct 50 points (min score 0)
    _score = max(0, _score - 50);

    try {
      if (_roomId.isNotEmpty && _userId.isNotEmpty) {
        await _service.submitScore(_roomId, _userId, _score);
      }
    } catch (_) {}

    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _selectedAnswerIndex = null;
      _isAnswered = false;
      _feedbackMessage = null;
      _hintUsed = false;
      _eliminatedAnswerIndices = [];
      notifyListeners();
      startTimer();
    } else {
      _isFinished = true;
      _timer?.cancel();
      _finishParticipantAndCheckRoom();
      notifyListeners();
    }
  }

  Future<void> _finishParticipantAndCheckRoom() async {
    if (_roomId.isEmpty || _userId.isEmpty) return;
    try {
      final firestore = FirebaseFirestore.instance;
      // 1. Update participant status to finished
      await firestore
          .collection('rooms')
          .doc(_roomId)
          .collection('participants')
          .doc(_userId)
          .set({
        'status': 'finished',
        'score': _score,
        'playerId': _userId,
      }, SetOptions(merge: true));

      // 2. Fetch all participants to check if everyone is finished
      final snapshot = await firestore
          .collection('rooms')
          .doc(_roomId)
          .collection('participants')
          .get();

      bool allFinished = true;
      for (final doc in snapshot.docs) {
        final st = doc.data()['status'] as String?;
        if (st != 'finished') {
          allFinished = false;
          break;
        }
      }

      // If all participants in the room are finished (or single player), set room status to finished
      if (allFinished || snapshot.docs.length <= 1) {
        await firestore.collection('rooms').doc(_roomId).update({
          'status': 'finished',
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
