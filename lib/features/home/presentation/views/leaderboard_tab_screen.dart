import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../quest_room/presentation/viewmodels/player_setup_view_model.dart';
import '../../../leaderboard/presentation/viewmodels/leaderboard_view_model.dart';
import '../../../leaderboard/presentation/widgets/top_three_podium.dart';
import '../../../leaderboard/presentation/widgets/user_sticky_card.dart';
import '../../../leaderboard/presentation/widgets/ranked_list_item.dart';

class LeaderboardTabScreen extends StatefulWidget {
  const LeaderboardTabScreen({super.key});

  @override
  State<LeaderboardTabScreen> createState() => _LeaderboardTabScreenState();
}

class _LeaderboardTabScreenState extends State<LeaderboardTabScreen> {
  final ScrollController _scrollController = ScrollController();
  late LeaderboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      final playerSetupVm = context.read<PlayerSetupViewModel>();
      final userId = authVm.currentUser?.uid ?? playerSetupVm.playerId ?? '';

      _viewModel = context.read<LeaderboardViewModel>();
      _viewModel.initUserRanking(userId);
      _viewModel.loadLeaderboard(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_viewModel.hasMore && !_viewModel.isLoading) {
        _viewModel.loadLeaderboard();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LeaderboardViewModel>();

    final topThree = vm.entries.take(3).toList();
    final restRankings = vm.entries.skip(3).toList();
    final totalGames = vm.entries.fold<int>(
      0,
      (sum, entry) => sum + entry.gamesPlayed,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Bảng Xếp Hạng 🏆',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () => vm.loadLeaderboard(refresh: true),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => vm.loadLeaderboard(refresh: true),
          child: vm.isLoading && vm.entries.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : vm.entries.isEmpty
              ? const _EmptyLeaderboardState()
              : ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  children: [
                    _LeaderboardHero(
                      totalPlayers: vm.entries.length,
                      totalGames: totalGames,
                    ),
                    const SizedBox(height: 22),
                    if (topThree.isNotEmpty) TopThreePodium(topThree: topThree),
                    if (vm.userRank != null) ...[
                      const SizedBox(height: 8),
                      UserStickyCard(userRank: vm.userRank!),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.leaderboard_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Bảng điểm tất cả người chơi',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...restRankings.map(
                      (entry) => RankedListItem(entry: entry),
                    ),
                    if (vm.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _LeaderboardHero extends StatelessWidget {
  final int totalPlayers;
  final int totalGames;

  const _LeaderboardHero({
    required this.totalPlayers,
    required this.totalGames,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF00796B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -36,
            right: -24,
            child: _HeroBubble(size: 118, opacity: 0.12),
          ),
          Positioned(
            bottom: -46,
            left: 64,
            child: _HeroBubble(size: 84, opacity: 0.08),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'TẤT CẢ THỜI GIAN',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Vinh danh những người chơi có tổng điểm cao nhất',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Điểm được cộng sau mỗi lượt chơi, giữ đúng tên và linh vật của người chơi.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.84),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _HeroStat(
                    icon: Icons.groups_rounded,
                    value: '$totalPlayers',
                    label: 'người chơi',
                  ),
                  const SizedBox(width: 12),
                  _HeroStat(
                    icon: Icons.sports_esports_rounded,
                    value: '$totalGames',
                    label: 'lượt chơi',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _HeroStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondaryContainer, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLeaderboardState extends StatelessWidget {
  const _EmptyLeaderboardState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        const Icon(
          Icons.emoji_events_outlined,
          size: 78,
          color: AppColors.outline,
        ),
        const SizedBox(height: 16),
        Text(
          'Chưa có xếp hạng',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Hoàn thành một ván quiz để ghi điểm đầu tiên.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _HeroBubble extends StatelessWidget {
  final double size;
  final double opacity;

  const _HeroBubble({required this.size, required this.opacity});

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
