import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../viewmodels/host_control_view_model.dart';
import '../widgets/player_status_card.dart';
import '../widgets/game_summary_cards.dart';
import '../widgets/action_control_bar.dart';

class HostControlScreen extends StatefulWidget {
  final String roomId;

  const HostControlScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<HostControlScreen> createState() => _HostControlScreenState();
}

class _HostControlScreenState extends State<HostControlScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // By default, the quiz has 4 questions in our mock list
      context.read<HostControlViewModel>().init(widget.roomId, 4);
    });
  }

  void _showEndGameConfirmation(BuildContext context, HostControlViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết Thúc Trò Chơi?'),
        content: const Text(
          'Hành động này sẽ đóng phòng thi đấu cho tất cả người chơi và chốt bảng xếp hạng chung cuộc. Bạn có chắc chắn muốn kết thúc?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              vm.endGame();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Kết Thúc'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HostControlViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Bảng Điều Khiển Chủ Phòng 🎛️',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => context.go('/home/quests'),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (vm.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (vm.errorMessage != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi nạp bảng điều khiển',
                          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        Text(vm.errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => vm.init(widget.roomId, 4),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              // Statistics header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: GameSummaryCards(
                  totalPlayers: vm.players.length,
                  completedCount: vm.completedCount,
                  timeRemaining: vm.timeRemaining,
                  players: vm.players,
                ),
              ),

              const SizedBox(height: 8),

              // Player section header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiến Độ Người Chơi Thời Gian Thực 📊',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${vm.players.length} người chơi',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Players progress list
              Expanded(
                child: vm.players.isEmpty
                    ? Center(
                        child: Text(
                          'Chưa có người chơi nào tham gia bảng theo dõi.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: vm.players.length,
                        itemBuilder: (context, index) {
                          return PlayerStatusCard(status: vm.players[index]);
                        },
                      ),
              ),

              // Host controls action panel
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ActionControlBar(
                  roomStatus: vm.roomStatus,
                  onPause: vm.pauseGame,
                  onResume: vm.resumeGame,
                  onEnd: () => _showEndGameConfirmation(context, vm),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
