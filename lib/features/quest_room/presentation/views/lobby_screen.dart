import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../viewmodels/lobby_view_model.dart';
import '../viewmodels/player_setup_view_model.dart';
import '../widgets/room_code_display.dart';
import '../widgets/player_avatar_grid.dart';
import '../../domain/entities/quest_room.dart';
import '../../../../core/di/di.dart';
import '../../application/services/i_quest_room_service.dart';

class LobbyScreen extends StatefulWidget {
  final String roomId;

  const LobbyScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen>
    with SingleTickerProviderStateMixin {
  late LobbyViewModel _lobbyVm;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _lobbyVm = context.read<LobbyViewModel>();
    _lobbyVm.init(widget.roomId);
    _lobbyVm.addListener(_onLobbyChanged);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _lobbyVm.removeListener(_onLobbyChanged);
    _fadeController.dispose();
    super.dispose();
  }

  void _onLobbyChanged() {
    if (!mounted) return;
    final room = _lobbyVm.room;
    if (room != null && room.status == RoomStatus.playing) {
      final authVm = context.read<AuthViewModel>();
      final user = authVm.currentUser;
      final isHost = (user != null && user.uid == room.hostId);

      if (isHost) {
        context.replace('/live-monitoring/${widget.roomId}');
      } else {
        context.replace('/quiz/${widget.roomId}');
      }
    }
  }

  Future<bool> _onWillPop() async {
    final authVm = context.read<AuthViewModel>();
    final playerSetupVm = context.read<PlayerSetupViewModel>();
    final isHost = authVm.currentUser?.uid == _lobbyVm.room?.hostId;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isHost
                      ? AppColors.errorContainer
                      : AppColors.secondaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isHost ? Icons.logout_rounded : Icons.exit_to_app_rounded,
                  color: isHost ? AppColors.error : AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isHost ? 'Đóng phòng game?' : 'Rời phòng chờ?',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isHost
                    ? 'Bạn có chắc chắn muốn hủy và đóng phòng chờ này? Tất cả người chơi khác sẽ bị ngắt kết nối.'
                    : 'Bạn có chắc chắn muốn rời khỏi phòng chờ này?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.outline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isHost ? AppColors.error : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(isHost ? 'Đóng phòng' : 'Rời phòng'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      if (isHost) {
        await getIt<IQuestRoomService>().deleteRoom(widget.roomId);
      } else {
        final myPlayerId = playerSetupVm.playerId ?? '';
        if (myPlayerId.isNotEmpty) {
          await _lobbyVm.leaveRoom(myPlayerId);
        }
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final lobbyVm = context.watch<LobbyViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final playerSetupVm = context.watch<PlayerSetupViewModel>();

    final room = lobbyVm.room;
    if (lobbyVm.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Đang tải phòng chờ...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (room == null) {
      return _buildNotFoundScreen();
    }

    final isHost = authVm.currentUser?.uid == room.hostId;
    final myPlayerId = isHost ? authVm.currentUser!.uid : (playerSetupVm.playerId ?? '');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        final proceed = await _onWillPop();
        if (proceed && mounted) {
          router.go('/home/quests');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Custom App Bar
                  _buildAppBar(context, isHost),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          // Topic Card
                          _TopicCard(topic: room.topic),
                          const SizedBox(height: 20),
                          // PIN Display
                          RoomCodeDisplay(pinCode: room.pinCode.padLeft(6, '0')),
                          const SizedBox(height: 24),
                          // Player Section
                          _buildPlayerSection(lobbyVm),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  // Bottom Action Panel
                  _buildBottomPanel(lobbyVm, isHost, myPlayerId),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isHost) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            onPressed: () async {
              final router = GoRouter.of(context);
              final proceed = await _onWillPop();
              if (proceed && mounted) {
                router.go('/home/quests');
              }
            },
          ),
          const Spacer(),
          // Title with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Phòng Chờ Game',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Room status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.tertiaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Chờ',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.tertiaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSection(LobbyViewModel lobbyVm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.group_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Người chơi đã vào',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryContainer,
                    AppColors.primary,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${lobbyVm.participants.length}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PlayerAvatarGrid(
          participants: lobbyVm.participants,
          hostId: _lobbyVm.room?.hostId,
        ),
      ],
    );
  }

  Widget _buildBottomPanel(LobbyViewModel lobbyVm, bool isHost, String myPlayerId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: isHost ? _buildHostPanel(lobbyVm) : _buildPlayerPanel(lobbyVm, myPlayerId),
    );
  }

  Widget _buildHostPanel(LobbyViewModel lobbyVm) {
    final canStart = lobbyVm.participants.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Start Game Button
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: ElevatedButton(
            onPressed: canStart ? lobbyVm.startQuest : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canStart ? AppColors.tertiaryContainer : AppColors.surfaceVariant,
              foregroundColor: canStart ? Colors.white : AppColors.outline,
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: canStart ? 4 : 0,
              shadowColor: canStart
                  ? AppColors.tertiaryContainer.withValues(alpha: 0.4)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canStart ? Icons.play_arrow_rounded : Icons.hourglass_empty_rounded,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  canStart ? 'Bắt đầu chơi' : 'Đang chờ người chơi...',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Close Room Button
        OutlinedButton(
          onPressed: () async {
            final router = GoRouter.of(context);
            final proceed = await _onWillPop();
            if (proceed && mounted) {
              router.go('/home/quests');
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(
              color: AppColors.error.withValues(alpha: 0.3),
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                'Hủy & Đóng Phòng',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
        if (!canStart) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: AppColors.outline,
              ),
              const SizedBox(width: 4),
              Text(
                'Cần ít nhất 1 người tham gia trước khi bắt đầu',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPlayerPanel(LobbyViewModel lobbyVm, String myPlayerId) {
    return Card(
      elevation: 0,
      color: AppColors.primaryContainer.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đang chờ chủ phòng...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Trò chơi sẽ bắt đầu sớm thôi',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                final router = GoRouter.of(context);
                if (myPlayerId.isNotEmpty) {
                  await lobbyVm.leaveRoom(myPlayerId);
                }
                if (mounted) {
                  router.go('/home/quests');
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'Rời phòng',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.errorContainer,
                      AppColors.errorContainer.withValues(alpha: 0.5),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Không tìm thấy phòng',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Phòng chơi này có thể đã bị đóng\nhoặc xóa bởi chủ phòng.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.outline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/home/quests'),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Quay lại Trang Chủ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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

class _TopicCard extends StatelessWidget {
  final String topic;

  const _TopicCard({required this.topic});

  IconData _getTopicIcon(String topic) {
    final lower = topic.toLowerCase();
    if (lower.contains('science') || lower.contains('technology') || lower.contains('khoa học') || lower.contains('công nghệ')) {
      return Icons.science_rounded;
    } else if (lower.contains('history') || lower.contains('culture') || lower.contains('lịch sử') || lower.contains('văn hóa')) {
      return Icons.museum_rounded;
    } else if (lower.contains('sport') || lower.contains('entertainment') || lower.contains('thể thao') || lower.contains('giải trí')) {
      return Icons.sports_soccer_rounded;
    } else if (lower.contains('geography') || lower.contains('nature') || lower.contains('địa lý') || lower.contains('thiên nhiên')) {
      return Icons.landscape_rounded;
    } else if (lower.contains('art') || lower.contains('music') || lower.contains('nghệ thuật') || lower.contains('âm nhạc')) {
      return Icons.palette_rounded;
    }
    return Icons.explore_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryContainer.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _getTopicIcon(topic),
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHỦ ĐỀ',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.outline,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.quiz_rounded,
                color: AppColors.secondaryContainer,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
