import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app_travel/features/quiz/presentation/viewmodels/quiz_viewmodel.dart';

class JoinQuestView extends StatefulWidget {
  const JoinQuestView({super.key});

  @override
  State<JoinQuestView> createState() => _JoinQuestViewState();
}

class _JoinQuestViewState extends State<JoinQuestView> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _joinGame() async {
    final viewModel = context.read<QuizViewModel>();
    final success = await viewModel.joinGame(_pinController.text, _nameController.text);
    if (success && mounted) {
      context.go('/question');
    } else if (mounted && viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<QuizViewModel>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: const Icon(Icons.explore_outlined, color: Color(0xFF003A55)),
        title: const Text(
          'TravelQuest',
          style: TextStyle(
            color: Color(0xFF003A55),
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Join a Quest',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003A55),
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'ROOM PIN CODE',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'NICKNAME',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _joinGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFDC55E),
                          foregroundColor: const Color(0xFF003A55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: isLoading 
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Join Game',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
