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
import '../../../leaderboard/presentation/widgets/season_reward_banner.dart';

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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (_viewModel.hasMore && !_viewModel.isLoading) {
        _viewModel.loadLeaderboard();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LeaderboardViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final playerSetupVm = context.watch<PlayerSetupViewModel>();
    final userId = authVm.currentUser?.uid ?? playerSetupVm.playerId ?? '';

    final topThree = vm.entries.take(3).toList();
    final restRankings = vm.entries.skip(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Bảng Xếp Hạng 🏆',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => vm.loadLeaderboard(refresh: true),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => vm.loadLeaderboard(refresh: true),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Segmented controls for switching periods
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPeriodChip(
                        context,
                        label: 'Mùa Tháng 7',
                        value: '2026-07',
                        currentValue: vm.period,
                        userId: userId,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPeriodChip(
                        context,
                        label: 'Tất Cả',
                        value: 'all-time',
                        currentValue: vm.period,
                        userId: userId,
                      ),
                    ),
                  ],
                ),
              ),

              // Active season reward banner
              if (vm.seasonEndDate != null || vm.rewardDescription != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                  child: SeasonRewardBanner(
                    seasonEndDate: vm.seasonEndDate,
                    rewardDescription: vm.rewardDescription,
                  ),
                ),

              // Main leaderboard content
              Expanded(
                child: vm.isLoading && vm.entries.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : vm.entries.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                              const Icon(
                                Icons.emoji_events_outlined,
                                size: 72,
                                color: AppColors.outline,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Chưa có xếp hạng',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : ListView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              // Top 3 Podium
                              if (topThree.isNotEmpty)
                                TopThreePodium(topThree: topThree),

                              // Sticky player rank banner
                              if (vm.userRank != null) ...[
                                UserStickyCard(userRank: vm.userRank!),
                                const SizedBox(height: 16),
                              ],

                              // Leaderboard list heading
                              if (restRankings.isNotEmpty) ...[
                                Text(
                                  'Bảng Điểm Toàn Cầu',
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Rank list item (4 and below)
                              ...restRankings.map(
                                (entry) => RankedListItem(entry: entry),
                              ),

                              // Loading footer for inf scroll
                              if (vm.isLoading)
                                const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(child: CircularProgressIndicator()),
                                ),

                              const SizedBox(height: 24),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(
    BuildContext context, {
    required String label,
    required String value,
    required String currentValue,
    required String userId,
  }) {
    final isSelected = value == currentValue;
    final vm = context.read<LeaderboardViewModel>();

    return ChoiceChip(
      label: Container(
        alignment: Alignment.center,
        height: 20,
        child: Text(label),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          vm.changePeriod(value, userId);
        }
      },
      selectedColor: AppColors.primaryContainer,
      backgroundColor: Colors.white,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: isSelected ? Colors.white : AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.transparent : AppColors.outlineVariant,
        ),
      ),
    );
  }
}
