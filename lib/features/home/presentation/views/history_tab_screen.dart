import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/system_quiz_presets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../quest_room/presentation/viewmodels/create_room_view_model.dart';
import '../../../quest_room/presentation/viewmodels/player_setup_view_model.dart';

class HistoryTabScreen extends StatefulWidget {
  const HistoryTabScreen({super.key});

  @override
  State<HistoryTabScreen> createState() => _HistoryTabScreenState();
}

class _HistoryTabScreenState extends State<HistoryTabScreen> {
  bool _isActionLoading = false;

  String _formatDate(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$h:$min - $d/$m/${dt.year}';
  }

  String _getQuizImage(String quizTitle) {
    final lower = quizTitle.toLowerCase();
    if (lower.contains('vũ trụ') || lower.contains('space') || lower.contains('khám phá vũ trụ')) {
      return 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=600&q=80';
    }
    if (lower.contains('công nghệ') || lower.contains('tech') || lower.contains('thần đồng công nghệ')) {
      return 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=600&q=80';
    }
    if (lower.contains('lịch sử') || lower.contains('sử việt') || lower.contains('hào hùng')) {
      return 'https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=600&q=80';
    }
    if (lower.contains('du lịch') || lower.contains('địa lý') || lower.contains('văn hóa')) {
      return 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=600&q=80';
    }
    return 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=600&q=80';
  }

  Future<void> _retryQuiz(Map<String, dynamic> item) async {
    final colors = Theme.of(context).colorScheme;
    final quizTitle = item['quizTitle'] as String? ?? 'Sử Việt Hào Hùng';
    var quizId = item['quizId'] as String? ?? '';
    final authVm = context.read<AuthViewModel>();
    final hostId = authVm.currentUser?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

    if (quizId.isEmpty) {
      final systemQuiz = SystemQuizPresets.findByTopic(quizTitle);
      if (systemQuiz != null) {
        quizId = systemQuiz.id;
      }
    }

    setState(() => _isActionLoading = true);

    try {
      final createVm = context.read<CreateRoomViewModel>();
      if (quizId.isNotEmpty) {
        createVm.selectQuiz(quizId, quizTitle);
      } else {
        createVm.setTopic(quizTitle);
      }
      createVm.toggleIsPublic(false);
      final room = await createVm.createRoom(hostId);

      if (!mounted) return;
      setState(() => _isActionLoading = false);
      if (room != null) {
        context.go('/quiz/${room.id}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(createVm.errorMessage ?? 'Không thể tạo bài luyện tập.'),
            backgroundColor: colors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isActionLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final playerSetupVm = context.watch<PlayerSetupViewModel>();
    final userId = authVm.currentUser?.uid ?? playerSetupVm.playerId ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Lịch Sử Luyện Tập 📜',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
            fontSize: 19,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Hero Header Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF00796B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'NHẬT KÝ BÀI THI CÁ NHÂN',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Lịch sử các lượt tự luyện tập Quiz',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Theo dõi tiến độ, tỷ lệ câu đúng và làm lại bài quiz bất cứ lúc nào.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // History Stream List
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: userId.isNotEmpty
                        ? FirebaseFirestore.instance
                            .collection('quiz_history')
                            .where('userId', isEqualTo: userId)
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('quiz_history')
                            .limit(30)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Không thể tải lịch sử làm bài.'),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const _EmptyHistoryState();
                      }

                      // Sort docs by completedAt descending locally
                      final items = docs.map((doc) => doc.data()).toList();
                      items.sort((a, b) {
                        final tA = (a['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                        final tB = (b['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                        return tB.compareTo(tA);
                      });

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final title = item['quizTitle'] as String? ?? 'Sử Việt Hào Hùng';
                          final correctCount = (item['correctCount'] as num?)?.toInt() ?? 0;
                          final totalQuestions = (item['totalQuestions'] as num?)?.toInt() ?? 0;
                          final completedAt = (item['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
                          final formattedDate = _formatDate(completedAt);
                          final imageUrl = _getQuizImage(title);

                          final percentage = totalQuestions > 0
                              ? ((correctCount / totalQuestions) * 100).round()
                              : 0;

                          Color statusBgColor;
                          Color statusTextColor;
                          if (percentage >= 70) {
                            statusBgColor = const Color(0xFFDCFCE7);
                            statusTextColor = const Color(0xFF15803D);
                          } else if (percentage >= 50) {
                            statusBgColor = const Color(0xFFFEF9C3);
                            statusTextColor = const Color(0xFFA16207);
                          } else {
                            statusBgColor = const Color(0xFFFEE2E2);
                            statusTextColor = const Color(0xFFB91C1C);
                          }

                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 14),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                children: [
                                  // Quiz Cover Image Thumbnail
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      imageUrl,
                                      width: 68,
                                      height: 68,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 68,
                                        height: 68,
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        child: const Icon(
                                          Icons.quiz_rounded,
                                          color: AppColors.primary,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Quiz Title & Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                                decoration: BoxDecoration(
                                                  color: statusBgColor,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'Đúng $correctCount/$totalQuestions câu ($percentage%)',
                                                  style: TextStyle(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: statusTextColor,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Hoàn thành: $formattedDate',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Button "Làm lại"
                                  ElevatedButton.icon(
                                    onPressed: () => _retryQuiz(item),
                                    icon: const Icon(Icons.refresh_rounded, size: 15),
                                    label: const Text('Làm lại'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: AppColors.onSecondary,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      visualDensity: VisualDensity.compact,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            if (_isActionLoading)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history_toggle_off_rounded,
              size: 72,
              color: AppColors.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có lịch sử làm bài',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy chọn một chủ đề hoặc bộ Quiz ở màn hình Trò Chơi để bắt đầu tự luyện tập nhé!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
