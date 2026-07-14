import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HostProgressView extends StatefulWidget {
  const HostProgressView({super.key});

  @override
  State<HostProgressView> createState() => _HostProgressViewState();
}

class _HostProgressViewState extends State<HostProgressView> {
  int _currentQuestion = 1;
  final int _totalQuestions = 10;
  final int _totalPlayers = 4;
  int _answeredPlayers = 3;

  void _nextQuestion() {
    if (_currentQuestion < _totalQuestions) {
      setState(() {
        _currentQuestion++;
        _answeredPlayers = 0; // Reset for next question
      });
      
      // Simulate players answering
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _answeredPlayers = 4;
          });
        }
      });
    } else {
      context.go('/leaderboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Question $_currentQuestion of $_totalQuestions',
          style: const TextStyle(
            color: Color(0xFF003A55),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
               context.go('/leaderboard');
            },
            child: const Text('End Game', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: _answeredPlayers / _totalPlayers,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade200,
                            color: Colors.teal,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_answeredPlayers',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF003A55),
                              ),
                            ),
                            Text(
                              'Answers',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Waiting for ${_totalPlayers - _answeredPlayers} players...',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDC55E),
                    foregroundColor: const Color(0xFF003A55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _currentQuestion < _totalQuestions ? 'Next Question' : 'Show Results',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
