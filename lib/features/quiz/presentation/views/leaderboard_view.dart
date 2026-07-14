import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app_travel/features/quiz/presentation/viewmodels/quiz_viewmodel.dart';

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<QuizViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Your Score: ${viewModel.score}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Top Players',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.leaderboard.length,
                itemBuilder: (context, index) {
                  final player = viewModel.leaderboard[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text('${player.score} pts', style: const TextStyle(fontSize: 16)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
