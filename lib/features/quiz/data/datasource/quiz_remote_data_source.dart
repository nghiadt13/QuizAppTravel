import 'package:quiz_app_travel/features/quiz/data/dtos/question_dto.dart';
import 'package:quiz_app_travel/features/quiz/data/dtos/player_dto.dart';

class QuizRemoteDataSource {
  Future<PlayerDto> joinRoom(String pin, String name) async {
    // Mock network delay
    await Future.delayed(const Duration(seconds: 1));
    if (pin != '123456') {
      throw Exception('Invalid PIN');
    }
    return PlayerDto(name: name, score: 0);
  }

  Future<List<QuestionDto>> fetchQuestions(String pin) async {
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(10, (index) {
      return QuestionDto(
        id: index + 1,
        content: 'Mock Question ${index + 1}: What is the capital of France?',
        options: ['London', 'Berlin', 'Paris', 'Madrid'],
        correctAnswerIndex: 2, // Paris
      );
    });
  }

  Future<void> submitScore(String pin, PlayerDto player) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock submit success
  }

  Future<List<PlayerDto>> fetchLeaderboard(String pin) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      PlayerDto(name: 'Nguyen Van A', score: 120),
      PlayerDto(name: 'Tran Thi B', score: 90),
      PlayerDto(name: 'Le Van C', score: 80),
      PlayerDto(name: 'Pham D', score: 60),
      PlayerDto(name: 'Hoang E', score: 40),
    ];
  }
}
