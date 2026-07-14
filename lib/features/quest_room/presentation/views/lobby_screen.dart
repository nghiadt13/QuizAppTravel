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

class LobbyScreen extends StatefulWidget {
  final String roomId;

  const LobbyScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late LobbyViewModel _lobbyVm;

  @override
  void initState() {
    super.initState();
    _lobbyVm = context.read<LobbyViewModel>();
    _lobbyVm.init(widget.roomId);
    _lobbyVm.addListener(_onLobbyChanged);
  }

  @override
  void dispose() {
    _lobbyVm.removeListener(_onLobbyChanged);
    super.dispose();
  }

  void _onLobbyChanged() {
    if (!mounted) return;
    final room = _lobbyVm.room;
    if (room != null && room.status == RoomStatus.playing) {
      context.replace('/quiz/${widget.roomId}');
    }
  }

  Future<bool> _onWillPop() async {
    final authVm = context.read<AuthViewModel>();
    final playerSetupVm = context.read<PlayerSetupViewModel>();

    // Show confirmation dialog before leaving
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Lobby?'),
        content: const Text('Are you sure you want to leave this quest lobby?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final isHost = authVm.currentUser?.uid == _lobbyVm.room?.hostId;
      final myPlayerId = isHost ? authVm.currentUser!.uid : (playerSetupVm.playerId ?? '');

      if (myPlayerId.isNotEmpty) {
        await _lobbyVm.leaveRoom(myPlayerId);
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (room == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lobby')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Room not found',
                  style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  'The room may have been closed or deleted by the host.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/home/quests'),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      );
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
        appBar: AppBar(
          title: Text(
            'Quest Lobby',
            style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () async {
              final router = GoRouter.of(context);
              final proceed = await _onWillPop();
              if (proceed && mounted) {
                router.go('/home/quests');
              }
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                
                // Topic card
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.primaryContainer,
                          child: Icon(Icons.landscape, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Topic',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                room.topic,
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // PIN display
                RoomCodeDisplay(pinCode: room.pinCode),
                const SizedBox(height: 24),

                // Joined players section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Joined Players',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.primary,
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${lobbyVm.participants.length}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Grid of players
                Expanded(
                  child: SingleChildScrollView(
                    child: PlayerAvatarGrid(
                      participants: lobbyVm.participants,
                      hostId: room.hostId,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Error message
                if (lobbyVm.errorMessage != null) ...[
                  Text(
                    lobbyVm.errorMessage!,
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],

                // Action panel at bottom
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: isHost
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: lobbyVm.participants.isNotEmpty
                                  ? lobbyVm.startQuest
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tertiaryContainer, // Lush Green
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Start Game',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (lobbyVm.participants.isEmpty)
                              Text(
                                'Need at least 1 player to join before starting',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.outline,
                                ),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        )
                      : Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.outlineVariant),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2.5),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Waiting for host to start...',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
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
                                  ),
                                  child: const Text('Leave'),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
