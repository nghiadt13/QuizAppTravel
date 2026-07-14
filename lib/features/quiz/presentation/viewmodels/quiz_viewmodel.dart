import 'package:flutter/material.dart';
import 'package:quiz_app_travel/features/quiz/application/services/i_quiz_service.dart';
import 'package:quiz_app_travel/features/quiz/domain/entities/player.dart';
import 'package:quiz_app_travel/features/quiz/domain/entities/question.dart';

class QuizViewModel extends ChangeNotifier {
  final IQuizService _quizService;

  QuizViewModel(this._quizService);

  bool isLoading = false;
  String? errorMessage;

  Player? currentPlayer;
  String currentPin = '';

  List<Question> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  
  // Khởi tạo sẵn danh sách Top Player mẫu cho màn hình Leaderboard
  List<Player> leaderboard = [
    Player(name: 'Nguyen Van A', score: 120),
    Player(name: 'Tran Thi B', score: 90),
    Player(name: 'Le Van C', score: 80),
    Player(name: 'Pham D', score: 60),
    Player(name: 'Hoang E', score: 40),
  ];

  Future<bool> joinGame(String pin, String name) async {
    _setLoading(true);
    try {
      currentPlayer = await _quizService.joinRoom(pin, name);
      currentPin = pin;
      questions = await _quizService.getQuestions(pin);
      currentQuestionIndex = 0;
      score = 0;
      _setLoading(false);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void answerQuestion(int selectedIndex) {
    if (questions.isEmpty || currentQuestionIndex >= questions.length) return;

    final correctIndex = questions[currentQuestionIndex].correctAnswerIndex;
    if (selectedIndex == correctIndex) {
      score += 10;
    }

    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      notifyListeners();
    } else {
      // Game over
      _finishGame();
    }
  }

  Future<void> _finishGame() async {
    if (currentPlayer == null) return;
    _setLoading(true);
    try {
      final updatedPlayer = Player(name: currentPlayer!.name, score: score);
      await _quizService.submitScore(currentPin, updatedPlayer);
      leaderboard = await _quizService.getLeaderboard(currentPin);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
