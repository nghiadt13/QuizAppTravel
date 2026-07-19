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
  bool _isJoining = false;

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
          content: Text('Vui lòng thiết lập biệt danh và avatar trước.'),
          backgroundColor: AppColors.coralOrange,
        ),
      );
      context.push('/player-setup');
      return;
    }

    playerSetupVm.generatePlayerId();

    setState(() => _isJoining = true);

    try {
      final room = await joinVm.joinRoom(
        pinCode: pinCode,
        displayName: playerSetupVm.displayName!,
        avatarId: playerSetupVm.avatarId!,
        playerId: playerSetupVm.playerId!,
      );

      if (mounted) {
        if (room != null) {
          context.replace('/lobby/${room.id}');
        } else {
          setState(() => _isJoining = false);
          if (joinVm.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(joinVm.errorMessage!)),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final browseVm = context.watch<BrowseQuestsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Phòng Game Công Khai',
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
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: browseVm.fetchPublicRooms,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Danh Sách Phòng Chờ 🌐',
                  style: AppTextStyles.displayLargeMobile.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tìm các phòng chơi nhiều người đang mở và cùng thử thách kiến thức nhé.',
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
                                  'Không có phòng chơi công khai',
                                  style: AppTextStyles.headlineMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Hiện tại không có phòng game nào đang mở cửa chờ người chơi. Hãy tự tạo một phòng mới ngay nhé!',
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
                                    child: const Text('Tạo phòng game'),
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
      if (_isJoining)
            Container(
              color: Colors.black.withValues(alpha: 0.45),
              child: const Center(
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          'Đang tham gia phòng game...',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
