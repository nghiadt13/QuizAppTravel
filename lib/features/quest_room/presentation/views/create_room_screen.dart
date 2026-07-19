import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../quiz/presentation/viewmodels/quiz_manager_view_model.dart';
import '../viewmodels/create_room_view_model.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      final hostId = authVm.currentUser?.uid;
      if (hostId != null) {
        context.read<QuizManagerViewModel>().fetchMyQuizzes(hostId);
      }
      context.read<QuizManagerViewModel>().fetchPublicQuizzes();
      context.read<CreateRoomViewModel>().resetSelection();
    });
  }

  Future<void> _onCreateRoom() async {
    final authVm = context.read<AuthViewModel>();
    final hostId = authVm.currentUser?.uid;

    if (hostId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chủ phòng chưa đăng nhập. Vui lòng đăng nhập trước.')),
      );
      context.go('/login');
      return;
    }

    final createVm = context.read<CreateRoomViewModel>();
    if (createVm.selectedQuizId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một bộ câu hỏi bên dưới để mở phòng.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final room = await createVm.createRoom(hostId);
    if (room != null && mounted) {
      context.replace('/lobby/${room.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final createVm = context.watch<CreateRoomViewModel>();
    final quizVm = context.watch<QuizManagerViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Tạo Phòng Game',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Mở Phòng Game Mới! 🚀',
                style: AppTextStyles.displayLargeMobile.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Chọn chủ đề, cấu hình các tùy chọn và mời bạn bè tham gia nhé.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Topic Input
              Text(
                'CHỌN BỘ CÂU HỎI ĐỂ CHƠI',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Title: BỘ CÂU HỎI CỦA BẠN
              Text(
                'BỘ CÂU HỎI CỦA BẠN',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              if (quizVm.myQuizzes.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Bạn chưa có bộ câu hỏi tự tạo nào.',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Hãy vào tab Cá nhân để tạo bộ câu hỏi riêng độc quyền!',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: quizVm.myQuizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = quizVm.myQuizzes[index];
                      final isSelected = createVm.selectedQuizId == quiz.id;

                      return GestureDetector(
                        onTap: () => createVm.selectQuiz(quiz.id, quiz.title),
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12, bottom: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.secondary : Colors.black.withValues(alpha: 0.05),
                              width: isSelected ? 3 : 1,
                            ),
                            image: quiz.imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(quiz.imageUrl!),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withValues(alpha: 0.4),
                                      BlendMode.darken,
                                    ),
                                  )
                                : null,
                            color: quiz.imageUrl == null ? AppColors.primary : null,
                          ),
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                quiz.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${quiz.questions.length} câu hỏi',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),

              // Title: BỘ CÂU HỎI HỆ THỐNG / CÔNG KHAI
              Text(
                'BỘ CÂU HỎI HỆ THỐNG / CÔNG KHAI',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              if (quizVm.publicQuizzes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text('Không có bộ câu hỏi công khai.')),
                )
              else
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: quizVm.publicQuizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = quizVm.publicQuizzes[index];
                      final isSelected = createVm.selectedQuizId == quiz.id;

                      return GestureDetector(
                        onTap: () => createVm.selectQuiz(quiz.id, quiz.title),
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12, bottom: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.secondary : Colors.black.withValues(alpha: 0.05),
                              width: isSelected ? 3 : 1,
                            ),
                            image: quiz.imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(quiz.imageUrl!),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withValues(alpha: 0.4),
                                      BlendMode.darken,
                                    ),
                                  )
                                : null,
                            color: quiz.imageUrl == null ? AppColors.primary : null,
                          ),
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                quiz.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${quiz.questions.length} câu hỏi',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),

              // Public Toggle
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.outlineVariant),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Phòng Công Khai',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  subtitle: Text(
                    'Cho phép người chơi khác nhìn thấy và tham gia vào phòng chơi của bạn từ danh sách phòng công khai.',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  value: createVm.isPublic,
                  onChanged: createVm.toggleIsPublic,
                  activeThumbColor: AppColors.tertiaryContainer, // Lush Green
                  inactiveTrackColor: AppColors.surfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Error notification
              if (createVm.errorMessage != null) ...[
                Text(
                  createVm.errorMessage!,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              // Create button
              ElevatedButton(
                onPressed: createVm.isLoading ? null : _onCreateRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Deep Ocean Blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: createVm.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Tạo Phòng & Mở Phòng Chờ',
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
}
