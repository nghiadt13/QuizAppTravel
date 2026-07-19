import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../../features/quest_room/presentation/viewmodels/player_setup_view_model.dart';
import '../viewmodels/open_chest_view_model.dart';
import '../widgets/treasure_chest.dart';
import '../widgets/reward_card.dart';
import '../widgets/sparkle_particles.dart';

class OpenChestScreen extends StatefulWidget {
  final String roomId;

  const OpenChestScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<OpenChestScreen> createState() => _OpenChestScreenState();
}

class _OpenChestScreenState extends State<OpenChestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OpenChestViewModel>().reset();
    });
  }

  void _onTapChest(String userId) {
    context.read<OpenChestViewModel>().tapChest(userId);
  }

  Future<void> _onClaim(String userId) async {
    final success = await context.read<OpenChestViewModel>().claimReward(userId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phần thưởng đã được thêm vào ví của bạn! 🎒'),
          backgroundColor: AppColors.tertiaryContainer,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OpenChestViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final playerSetupVm = context.watch<PlayerSetupViewModel>();
    final userId = authVm.currentUser?.uid ?? playerSetupVm.playerId ?? 'anonymous';

    return Scaffold(
      backgroundColor: const Color(0xFFF4EBE1), // Vintage parchment background
      appBar: AppBar(
        title: Text(
          'Phòng Kho Báu',
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
        child: Stack(
          children: [
            // Vintage map decorations (watermark)
            Positioned(
              right: -50,
              top: 40,
              child: Opacity(
                opacity: 0.05,
                child: Icon(Icons.explore, size: 240, color: AppColors.primary),
              ),
            ),
            Positioned(
              left: -40,
              bottom: 40,
              child: Opacity(
                opacity: 0.05,
                child: Icon(Icons.public, size: 200, color: AppColors.primary),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Stage Header
                  Text(
                    vm.isOpened ? 'Tìm Thấy Kho Báu! 🎉' : 'Nhận Phần Thưởng! 🎁',
                    style: AppTextStyles.displayLargeMobile.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vm.isOpened
                        ? 'Chúc mừng! Bạn đã mở khóa một phần thưởng đặc biệt.'
                        : 'Chạm 3 lần vào rương kho báu huyền thoại để mở khóa phần thưởng.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Scrollable middle area (chest + reward)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Game Area
                          SizedBox(
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SparkleParticles(play: vm.isOpened),
                                TreasureChest(
                                  isShaking: vm.isShaking,
                                  isOpened: vm.isOpened,
                                  onTap: () => _onTapChest(userId),
                                ),
                              ],
                            ),
                          ),

                          // Tap counter prompt
                          if (!vm.isOpened) ...[
                            const SizedBox(height: 12),
                            Text(
                              'GÕ: ${vm.tapCount}/3',
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.coralOrange,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],

                          // Reward Card reveal
                          if (vm.isOpened && vm.reward != null) ...[
                            const SizedBox(height: 16),
                            RewardCard(reward: vm.reward!),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Error notice
                  if (vm.errorMessage != null) ...[
                    Text(
                      vm.errorMessage!,
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Actions button (always at bottom)
                  if (vm.isOpened) ...[
                    if (!vm.isClaimed)
                      ElevatedButton(
                        onPressed: vm.isLoading ? null : () => _onClaim(userId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryContainer,
                          foregroundColor: AppColors.onSecondaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: vm.isLoading
                            ? const CircularProgressIndicator()
                            : Text(
                                'Thêm Vào Ví',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          vm.reset();
                          context.go('/home/leaderboard');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Xem Bảng Xếp Hạng Mùa',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
