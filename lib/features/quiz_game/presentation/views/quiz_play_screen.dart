import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  const QuizPlayScreen({super.key, required this.roomId});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  bool _hasSavedHistory = false;

  void _saveQuizHistory(QuizPlayViewModel quizVm, String userId) {
    if (_hasSavedHistory) return;
    _hasSavedHistory = true;

    try {
      final quizTitle = quizVm.roomTopic.isNotEmpty
          ? quizVm.roomTopic
          : 'Sử Việt Hào Hùng';

      FirebaseFirestore.instance.collection('quiz_history').add({
        'userId': userId,
        'quizTitle': quizTitle,
        'quizId': quizVm.quizId ?? '',
        'score': quizVm.score,
        'correctCount': quizVm.correctAnswersCount,
        'totalQuestions': quizVm.questions.length,
        'completedAt': DateTime.now(),
      });
    } catch (_) {}
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      final playerSetupVm = context.read<PlayerSetupViewModel>();
      final userId =
          playerSetupVm.playerId ?? authVm.currentUser?.uid ?? 'anonymous';

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
                'Đang tải câu hỏi...',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
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
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Lỗi tải câu hỏi',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.primary,
                  ),
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
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (quizVm.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vòng Thi')),
        body: const Center(child: Text('Không tìm thấy câu hỏi.')),
      );
    }

    // Game Finished Summary View
    if (quizVm.isFinished) {
      final authVm = context.read<AuthViewModel>();
      final playerSetupVm = context.read<PlayerSetupViewModel>();
      final userId = authVm.currentUser?.uid ?? playerSetupVm.playerId ?? '';
      _saveQuizHistory(quizVm, userId);

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '🏆',
                  style: TextStyle(fontSize: 64),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Trận đấu hoàn thành!',
                  style: AppTextStyles.displayLargeMobile.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Chúc mừng! Bạn đã hoàn thành bài thi.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Score Box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            'TỔNG ĐIỂM CỦA BẠN',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.outline,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${quizVm.score} pts',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.secondary, // Sunny Yellow Gold
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Quiz performance summary cards (Correct vs Incorrect)
                Row(
                  children: [
                    // Correct answers card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'SỐ CÂU ĐÚNG',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${quizVm.correctAnswersCount}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Incorrect answers card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'SỐ CÂU SAI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB91C1C),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${quizVm.incorrectAnswersCount}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Finish Game & Back to Home Button
                ElevatedButton.icon(
                  onPressed: () {
                    context.go('/home/quests');
                  },
                  icon: const Icon(Icons.home_rounded, size: 22),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  label: Text(
                    'HOÀN THÀNH & VỀ TRANG CHỦ',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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
          'Đấu Trường Quiz',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
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
                            'Cố lên!',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.outline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Điểm tốc độ kích hoạt ⚡',
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
                        final isEliminated = quizVm.eliminatedAnswerIndices
                            .contains(idx);

                        return AnswerOptionTile(
                          optionText: question.options[idx],
                          index: idx,
                          isSelected: isSelected,
                          isCorrect: isCorrectOption,
                          hasBeenAnswered: quizVm.isAnswered,
                          isEliminated: isEliminated,
                          onTap: () {
                            final authVm = context.read<AuthViewModel>();
                            final playerSetupVm = context
                                .read<PlayerSetupViewModel>();
                            final userId =
                                authVm.currentUser?.uid ??
                                playerSetupVm.playerId ??
                                'anonymous';
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
                        ? 'Câu tiếp theo'
                        : 'Hoàn thành',
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
            if (quizVm.feedbackMessage != null && quizVm.feedbackMessage!.isNotEmpty)
              Positioned(
                bottom: 90,
                left: 0,
                right: 0,
                child: FeedbackToast(
                  message: quizVm.feedbackMessage!,
                  isCorrect: isCorrect,
                  visible: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
