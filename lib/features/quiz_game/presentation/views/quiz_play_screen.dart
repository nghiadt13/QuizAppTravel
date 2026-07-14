import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../presentation/viewmodels/quiz_play_view_model.dart';
import '../../presentation/widgets/countdown_timer.dart';
import '../../presentation/widgets/question_card.dart';
import '../../presentation/widgets/answer_option_tile.dart';
import '../../presentation/widgets/feedback_toast.dart';
import '../../presentation/widgets/hint_button.dart';
import '../../../../features/quest_room/presentation/viewmodels/player_setup_view_model.dart';

class QuizPlayScreen extends StatefulWidget {
  final String roomId;

  const QuizPlayScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      final playerSetupVm = context.read<PlayerSetupViewModel>();
      final userId = authVm.currentUser?.uid ?? playerSetupVm.playerId ?? 'anonymous';

      final quizVm = context.read<QuizPlayViewModel>();
      quizVm.setRoomAndUser(widget.roomId, userId);
      quizVm.loadQuestions(widget.roomId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizVm = context.watch<QuizPlayViewModel>();

    if (quizVm.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Preparing your quest...',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    if (quizVm.errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Quest Error',
                  style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  quizVm.errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    quizVm.loadQuestions(widget.roomId);
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (quizVm.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Play')),
        body: const Center(child: Text('No questions found.')),
      );
    }

    // Game Finished Summary View
    if (quizVm.isFinished) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Text(
                  '🏆',
                  style: TextStyle(fontSize: 80),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Quest Completed!',
                  style: AppTextStyles.displayLargeMobile.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You traveled far and tested your knowledge. Here is your final score:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Score Box
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TOTAL SCORE',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.outline,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${quizVm.score}',
                        style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.secondary, // Sunny Yellow Gold
                          fontWeight: FontWeight.w900,
                          fontSize: 64,
                        ),
                      ),
                      Text(
                        'points',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Reward Claim Button
                ElevatedButton(
                  onPressed: () {
                    context.replace('/reward/${widget.roomId}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiaryContainer, // Lush Green
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Claim Reward & Finish',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = quizVm.currentQuestion!;
    final isCorrect = quizVm.selectedAnswerIndex == question.correctIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Quiz Challenge',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevent going back mid-game
        actions: [
          // Score Badge in AppBar
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer, // Sunny Yellow
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text(
                  '${quizVm.score}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Timer and Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keep going!',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.outline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Speed bonus active ⚡',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.tertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Beautiful Countdown Timer
                      CountdownTimer(
                        timeRemaining: quizVm.timeRemaining,
                        totalTime: question.timeLimit,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Question Card
                  QuestionCard(
                    question: question,
                    currentQuestionIndex: quizVm.currentQuestionIndex,
                    totalQuestions: quizVm.questions.length,
                  ),
                  const SizedBox(height: 24),

                  // Option Tiles
                  Expanded(
                    child: ListView.builder(
                      itemCount: question.options.length,
                      itemBuilder: (context, idx) {
                        final isSelected = quizVm.selectedAnswerIndex == idx;
                        final isCorrectOption = question.correctIndex == idx;
                        final isEliminated = quizVm.eliminatedAnswerIndices.contains(idx);

                        return AnswerOptionTile(
                          optionText: question.options[idx],
                          index: idx,
                          isSelected: isSelected,
                          isCorrect: isCorrectOption,
                          hasBeenAnswered: quizVm.isAnswered,
                          isEliminated: isEliminated,
                          onTap: () {
                            final authVm = context.read<AuthViewModel>();
                            final playerSetupVm = context.read<PlayerSetupViewModel>();
                            final userId = authVm.currentUser?.uid ?? playerSetupVm.playerId ?? 'anonymous';
                            quizVm.selectAnswer(idx, widget.roomId, userId);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Next button or Action Footer overlay
            if (quizVm.isAnswered)
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: ElevatedButton(
                  onPressed: quizVm.nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    quizVm.currentQuestionIndex < quizVm.questions.length - 1
                        ? 'Next Question'
                        : 'Finish Quest',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              // Hint Button as Floating lightbulb aligned bottom-right
              Positioned(
                bottom: 24,
                right: 24,
                child: HintButton(
                  isUsed: quizVm.hintUsed,
                  onTap: quizVm.useHint,
                  disabled: quizVm.isAnswered,
                ),
              ),

            // Animated points / feedback toast at bottom
            Positioned(
              bottom: 90,
              left: 0,
              right: 0,
              child: FeedbackToast(
                message: quizVm.feedbackMessage ?? '',
                isCorrect: isCorrect,
                visible: quizVm.feedbackMessage != null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
