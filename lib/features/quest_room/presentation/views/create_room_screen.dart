import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../quiz/domain/entities/quiz_set.dart';
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
        const SnackBar(
          content: Text('Chủ phòng chưa đăng nhập. Vui lòng đăng nhập trước.'),
        ),
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
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final horizontalPadding = constraints.maxWidth < 520
                ? 16.0
                : constraints.maxWidth < 900
                ? 24.0
                : 40.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 1120 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CreateRoomHero(selectedTopic: createVm.topic),
                      const SizedBox(height: 26),
                      _SectionTitle(
                        title: 'CHỌN BỘ CÂU HỎI ĐỂ CHƠI',
                        subtitle:
                            'Bộ hệ thống có sẵn câu hỏi, có thể dùng để luyện tập hoặc mở phòng đấu ngay.',
                      ),
                      const SizedBox(height: 18),
                      _PersonalQuizSection(
                        quizzes: quizVm.myQuizzes,
                        selectedQuizId: createVm.selectedQuizId,
                        onSelect: createVm.selectQuiz,
                        onCreateQuiz: () {
                          final authVm = context.read<AuthViewModel>();
                          final userId =
                              authVm.currentUser?.uid ??
                              'guest_${DateTime.now().millisecondsSinceEpoch}';
                          context.read<QuizManagerViewModel>().startNewQuiz(
                            userId,
                          );
                          context.push('/create-quiz');
                        },
                      ),
                      const SizedBox(height: 22),
                      _SystemQuizSection(
                        isLoading:
                            quizVm.isLoading && quizVm.publicQuizzes.isEmpty,
                        quizzes: quizVm.publicQuizzes,
                        selectedQuizId: createVm.selectedQuizId,
                        onSelect: createVm.selectQuiz,
                      ),
                      const SizedBox(height: 24),
                      _PublicRoomSwitch(
                        value: createVm.isPublic,
                        onChanged: createVm.toggleIsPublic,
                      ),
                      const SizedBox(height: 22),
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
                      Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWide ? 520 : double.infinity,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: createVm.isLoading
                                  ? null
                                  : _onCreateRoom,
                              icon: createVm.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.rocket_launch_rounded),
                              label: Text(
                                createVm.isLoading
                                    ? 'Đang mở phòng...'
                                    : 'Tạo Phòng & Mở Phòng Chờ',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 3,
                                shadowColor: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CreateRoomHero extends StatelessWidget {
  final String selectedTopic;

  const _CreateRoomHero({required this.selectedTopic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF087989)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -18,
            child: _GlowCircle(size: 110, opacity: 0.12),
          ),
          Positioned(
            bottom: -42,
            left: 80,
            child: _GlowCircle(size: 86, opacity: 0.08),
          ),
          Column(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.secondaryContainer,
                size: 30,
              ),
              const SizedBox(height: 10),
              Text(
                'Mở Phòng Game Mới! 🚀',
                style: AppTextStyles.displayLargeMobile.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                selectedTopic.isEmpty
                    ? 'Chọn bộ câu hỏi, bật phòng công khai và mời bạn bè cùng thử thách.'
                    : 'Đang chọn: $selectedTopic',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.86),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PersonalQuizSection extends StatelessWidget {
  final List<QuizSet> quizzes;
  final String? selectedQuizId;
  final void Function(String? quizId, String quizTitle) onSelect;
  final VoidCallback onCreateQuiz;

  const _PersonalQuizSection({
    required this.quizzes,
    required this.selectedQuizId,
    required this.onSelect,
    required this.onCreateQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return _QuizSectionFrame(
      title: 'Bộ câu hỏi của bạn',
      child: quizzes.isEmpty
          ? _EmptyPersonalQuizCard(onCreateQuiz: onCreateQuiz)
          : _ResponsiveQuizGrid(
              quizzes: quizzes,
              selectedQuizId: selectedQuizId,
              onSelect: onSelect,
            ),
    );
  }
}

class _SystemQuizSection extends StatelessWidget {
  final bool isLoading;
  final List<QuizSet> quizzes;
  final String? selectedQuizId;
  final void Function(String? quizId, String quizTitle) onSelect;

  const _SystemQuizSection({
    required this.isLoading,
    required this.quizzes,
    required this.selectedQuizId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return _QuizSectionFrame(
      title: 'Bộ câu hỏi hệ thống / công khai',
      badge: quizzes.isEmpty ? null : '${quizzes.length} bộ sẵn sàng',
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          : _ResponsiveQuizGrid(
              quizzes: quizzes,
              selectedQuizId: selectedQuizId,
              onSelect: onSelect,
            ),
    );
  }
}

class _QuizSectionFrame extends StatelessWidget {
  final String title;
  final String? badge;
  final Widget child;

  const _QuizSectionFrame({
    required this.title,
    this.badge,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ResponsiveQuizGrid extends StatelessWidget {
  final List<QuizSet> quizzes;
  final String? selectedQuizId;
  final void Function(String? quizId, String quizTitle) onSelect;

  const _ResponsiveQuizGrid({
    required this.quizzes,
    required this.selectedQuizId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width < 520
            ? 1
            : width < 860
            ? 2
            : 3;
        final tileHeight = width < 520 ? 172.0 : 190.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: tileHeight,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 260 + index * 45),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: _QuizChoiceCard(
                quiz: quiz,
                index: index,
                isSelected: quiz.id == selectedQuizId,
                onTap: () => onSelect(quiz.id, quiz.title),
              ),
            );
          },
        );
      },
    );
  }
}

class _QuizChoiceCard extends StatelessWidget {
  final QuizSet quiz;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuizChoiceCard({
    required this.quiz,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = _cardGradient(index);
    final hasImage = quiz.imageUrl != null && quiz.imageUrl!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            image: hasImage
                ? DecorationImage(
                    image: NetworkImage(quiz.imageUrl!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.38),
                      BlendMode.darken,
                    ),
                  )
                : null,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? AppColors.secondaryContainer : Colors.white,
              width: isSelected ? 3 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (isSelected
                            ? AppColors.secondaryContainer
                            : gradient.colors.last)
                        .withValues(alpha: isSelected ? 0.28 : 0.16),
                blurRadius: isSelected ? 22 : 12,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -24,
                right: -20,
                child: _GlowCircle(size: 94, opacity: hasImage ? 0.08 : 0.14),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _quizIcon(index),
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    quiz.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quiz.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QuizMetaPill(
                        icon: Icons.quiz_rounded,
                        label: '${quiz.questions.length} câu',
                      ),
                      const SizedBox(width: 8),
                      _QuizMetaPill(
                        icon: quiz.creatorId == 'system'
                            ? Icons.verified_rounded
                            : Icons.public_rounded,
                        label: quiz.creatorId == 'system'
                            ? 'Hệ thống'
                            : 'Công khai',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _cardGradient(int index) {
    const gradients = [
      LinearGradient(
        colors: [Color(0xFF5E35B1), Color(0xFF4527A0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Color(0xFF039BE5), Color(0xFF006D9C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Color(0xFF8D6E63), Color(0xFF4E342E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Color(0xFF2E7D32), Color(0xFF145A1F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Color(0xFF00897B), Color(0xFF00564D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];
    return gradients[index % gradients.length];
  }

  IconData _quizIcon(int index) {
    const icons = [
      Icons.rocket_launch_rounded,
      Icons.computer_rounded,
      Icons.hourglass_bottom_rounded,
      Icons.eco_rounded,
      Icons.auto_awesome_rounded,
    ];
    return icons[index % icons.length];
  }
}

class _QuizMetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuizMetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPersonalQuizCard extends StatelessWidget {
  final VoidCallback onCreateQuiz;

  const _EmptyPersonalQuizCard({required this.onCreateQuiz});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondaryContainer.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn chưa có bộ câu hỏi tự tạo.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Có thể dùng bộ hệ thống bên dưới hoặc tạo bộ riêng cho nhóm.',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: onCreateQuiz,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Tạo mới'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicRoomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PublicRoomSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          'Phòng Công Khai',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          'Người chơi khác có thể thấy và tham gia phòng từ danh sách công khai.',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.tertiaryContainer,
        inactiveTrackColor: AppColors.surfaceVariant,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _GlowCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
