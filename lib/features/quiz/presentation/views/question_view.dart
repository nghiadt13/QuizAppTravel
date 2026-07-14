import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app_travel/features/quiz/presentation/viewmodels/quiz_viewmodel.dart';

class QuestionView extends StatelessWidget {
  const QuestionView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QuizViewModel>();

    if (viewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Question')),
        body: const Center(child: Text('No questions found.')),
      );
    }

    // Checking if the game just finished.
    // In actual implementation, we might navigate to leaderboard instead of checking this here,
    // but doing a post-frame callback is safer if we want to auto-redirect.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.currentQuestionIndex >= viewModel.questions.length - 1 && viewModel.leaderboard.isNotEmpty) {
        context.go('/leaderboard');
      }
    });

    final currentQuestion = viewModel.questions[viewModel.currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${viewModel.currentQuestionIndex + 1} of ${viewModel.questions.length}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Score: ${viewModel.score}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Text(
                  currentQuestion.content,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(currentQuestion.options.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  onPressed: () {
                    viewModel.answerQuestion(index);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    currentQuestion.options[index],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
