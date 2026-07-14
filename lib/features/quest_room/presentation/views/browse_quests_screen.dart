import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../viewmodels/browse_quests_view_model.dart';
import '../viewmodels/player_setup_view_model.dart';
import '../viewmodels/join_room_view_model.dart';
import '../widgets/quest_card_tile.dart';

class BrowseQuestsScreen extends StatefulWidget {
  const BrowseQuestsScreen({super.key});

  @override
  State<BrowseQuestsScreen> createState() => _BrowseQuestsScreenState();
}

class _BrowseQuestsScreenState extends State<BrowseQuestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrowseQuestsViewModel>().fetchPublicRooms();
    });
  }

  Future<void> _joinPublicRoom(String pinCode) async {
    final playerSetupVm = context.read<PlayerSetupViewModel>();
    final joinVm = context.read<JoinRoomViewModel>();

    if (playerSetupVm.displayName == null || playerSetupVm.avatarId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set up your profile name and avatar first.'),
          backgroundColor: AppColors.coralOrange,
        ),
      );
      context.push('/player-setup');
      return;
    }

    playerSetupVm.generatePlayerId();

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final room = await joinVm.joinRoom(
      pinCode: pinCode,
      displayName: playerSetupVm.displayName!,
      avatarId: playerSetupVm.avatarId!,
      playerId: playerSetupVm.playerId!,
    );

    if (mounted) {
      context.pop(); // Pop loading dialog
    }

    if (room != null && mounted) {
      context.replace('/lobby/${room.id}');
    } else if (joinVm.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(joinVm.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final browseVm = context.watch<BrowseQuestsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Public Quests',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home/quests');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: browseVm.fetchPublicRooms,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: browseVm.fetchPublicRooms,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Browse Active Lobbies 🌐',
                  style: AppTextStyles.displayLargeMobile.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Find open multiplayer lobbies and test your travel knowledge together.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                if (browseVm.errorMessage != null) ...[
                  Text(
                    browseVm.errorMessage!,
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],

                Expanded(
                  child: browseVm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : browseVm.rooms.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                                Icon(
                                  Icons.explore_off_outlined,
                                  size: 72,
                                  color: AppColors.outline.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Active Public Quests',
                                  style: AppTextStyles.headlineMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'There are no public games waiting for players right now. Go host one yourself!',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                                  child: ElevatedButton(
                                    onPressed: () => context.push('/create-room'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Host a Quest'),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              itemCount: browseVm.rooms.length,
                              itemBuilder: (context, index) {
                                final room = browseVm.rooms[index];
                                return QuestCardTile(
                                  room: room,
                                  onTap: () => _joinPublicRoom(room.pinCode),
                                );
                              },
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
