import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/player_live_status.dart';

class GameSummaryCards extends StatelessWidget {
  final int totalPlayers;
  final int completedCount;
  final int timeRemaining;
  final List<PlayerLiveStatus> players;

  const GameSummaryCards({
    super.key,
    required this.totalPlayers,
    required this.completedCount,
    required this.timeRemaining,
    required this.players,
  });

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double _getAverageProgress() {
    if (players.isEmpty) return 0.0;
    int sumIndex = 0;
    int sumTotal = 0;
    for (final p in players) {
      sumIndex += p.currentQuestionIndex;
      sumTotal += p.totalQuestions;
    }
    if (sumTotal == 0) return 0.0;
    return sumIndex / sumTotal;
  }

  @override
  Widget build(BuildContext context) {
    final progressPercentage = (_getAverageProgress() * 100).toStringAsFixed(0);
    final ratioText = '$completedCount/$totalPlayers';
    final timeStr = _formatTime(timeRemaining);

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.9,
      children: [
        // Bento Card 1: Completed Ratio
        _buildBentoCard(
          context,
          icon: Icons.check_circle_outline,
          iconColor: AppColors.tertiaryContainer,
          title: 'Finished',
          value: ratioText,
          subtitle: 'players done',
        ),

        // Bento Card 2: Time Remaining
        _buildBentoCard(
          context,
          icon: Icons.timer_outlined,
          iconColor: AppColors.coralOrange,
          title: 'Time Left',
          value: timeStr,
          subtitle: timeRemaining <= 30 ? 'closing soon!' : 'minutes remaining',
        ),

        // Bento Card 3: Current Question Progress
        _buildBentoCard(
          context,
          icon: Icons.trending_up,
          iconColor: AppColors.primary,
          title: 'Progress',
          value: '$progressPercentage%',
          subtitle: 'average complete',
        ),
      ],
    );
  }

  Widget _buildBentoCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.05),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.outline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(icon, color: iconColor, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
