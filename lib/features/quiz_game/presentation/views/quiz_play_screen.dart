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
import '../../../../core/di/di.dart';
import '../../../../features/quest_room/application/services/i_quest_room_service.dart';
import '../../../../features/quest_room/domain/entities/participant.dart';
import '../../../../features/leaderboard/application/services/i_leaderboard_service.dart';

class QuizPlayScreen extends StatefulWidget {
  final String roomId;

  const QuizPlayScreen({super.key, required this.roomId});

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
    final authVm = context.watch<AuthViewModel>();
    final playerSetupVm = context.watch<PlayerSetupViewModel>();
    final userId =
        playerSetupVm.playerId ?? authVm.currentUser?.uid ?? 'anonymous';

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

                // Live room scoreboard section
                Row(
                  children: [
                    const Icon(
                      Icons.analytics_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'BẢNG XẾP HẠNG PHÒNG GAME',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                StreamBuilder<List<Participant>>(
                  stream: getIt<IQuestRoomService>().watchParticipants(
                    widget.roomId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Không thể tải bảng điểm thời gian thực.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final participants = List<Participant>.from(snapshot.data!);
                    // Sort participants by score descending, then by joinedAt
                    participants.sort((a, b) {
                      final scoreComparison = b.score.compareTo(a.score);
                      if (scoreComparison != 0) return scoreComparison;
                      return a.joinedAt.compareTo(b.joinedAt);
                    });

                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: participants.length,
                          separatorBuilder: (context, index) => Divider(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final p = participants[index];
                            final isMe = p.playerId == userId;
                            final rank = index + 1;

                            Widget rankWidget;
                            if (rank == 1) {
                              rankWidget = const Text(
                                '🥇',
                                style: TextStyle(fontSize: 20),
                              );
                            } else if (rank == 2) {
                              rankWidget = const Text(
                                '🥈',
                                style: TextStyle(fontSize: 20),
                              );
                            } else if (rank == 3) {
                              rankWidget = const Text(
                                '🥉',
                                style: TextStyle(fontSize: 20),
                              );
                            } else {
                              rankWidget = Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.05,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$rank',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final emoji = _getEmoji(p.avatarId);
                            final avatarBg = _getAvatarBg(p.avatarId);

                            return Container(
                              color: isMe
                                  ? AppColors.primary.withValues(alpha: 0.03)
                                  : Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: [
                                  rankWidget,
                                  const SizedBox(width: 12),

                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: avatarBg,
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Text(
                                      p.displayName + (isMe ? ' (Bạn)' : ''),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isMe
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isMe
                                            ? AppColors.primary
                                            : AppColors.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${p.score} pts',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isMe
                                              ? AppColors.secondary
                                              : AppColors.primary,
                                        ),
                                      ),
                                      if (p.status == ParticipantStatus.playing)
                                        Text(
                                          'Đang trả lời...',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.onSurfaceVariant
                                                .withValues(alpha: 0.6),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Finish Game & Back to Home Button
                ElevatedButton.icon(
                  onPressed: () async {
                    final score = quizVm.score;
                    final router = GoRouter.of(context);
                    if (userId.isNotEmpty && userId != 'anonymous') {
                      try {
                        final displayName =
                            playerSetupVm.displayName ??
                            authVm.currentUser?.displayName ??
                            'Người chơi';
                        final avatarUrl =
                            playerSetupVm.avatarId ??
                            authVm.currentUser?.avatarUrl;
                        await getIt<ILeaderboardService>().submitGameScore(
                          'all-time',
                          userId,
                          score,
                          displayName: displayName,
                          avatarUrl: avatarUrl,
                        );
                      } catch (_) {}
                    }
                    router.go('/home/quests');
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

  String _getEmoji(String avatarUrl) {
    switch (avatarUrl.toLowerCase()) {
      case 'dog':
        return '🐶';
      case 'cat':
        return '🐱';
      case 'bird':
        return '🐦';
      case 'rabbit':
        return '🐰';
      case 'fox':
        return '🦊';
      case 'owl':
        return '🦉';
      case 'panda':
        return '🐼';
      case 'bear':
        return '🐻';
      case 'koala':
        return '🐨';
      case 'penguin':
        return '🐧';
      case 'monkey':
        return '🐵';
      case 'tiger':
        return '🐯';
      default:
        return '👤';
    }
  }

  Color _getAvatarBg(String avatarUrl) {
    switch (avatarUrl.toLowerCase()) {
      case 'dog':
        return const Color(0xFFFFECE0);
      case 'cat':
        return const Color(0xFFE8F5E9);
      case 'bird':
        return const Color(0xFFE3F2FD);
      case 'rabbit':
        return const Color(0xFFF3E5F5);
      case 'fox':
        return const Color(0xFFFFF3E0);
      case 'owl':
        return const Color(0xFFECEFF1);
      case 'panda':
        return const Color(0xFFF5F5F5);
      case 'bear':
        return const Color(0xFFFFF8E1);
      case 'koala':
        return const Color(0xFFE0F2F1);
      case 'penguin':
        return const Color(0xFFE1F5FE);
      case 'monkey':
        return const Color(0xFFFFF1E6);
      case 'tiger':
        return const Color(0xFFFFE0B2);
      default:
        return AppColors.surfaceVariant;
    }
  }
}
