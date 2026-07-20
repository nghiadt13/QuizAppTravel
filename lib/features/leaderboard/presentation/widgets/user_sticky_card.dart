import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/leaderboard_entry.dart';
import 'leaderboard_avatar.dart';

class UserStickyCard extends StatelessWidget {
  final LeaderboardEntry userRank;

  const UserStickyCard({super.key, required this.userRank});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primaryContainer.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.primaryContainer, // Deep Ocean Blue light variant
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            // User Rank
            Text(
              '#${userRank.rank}',
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 16),

            // Avatar
            LeaderboardAvatar(
              avatarUrl: userRank.avatarUrl,
              size: 44,
              fontSize: 24,
            ),
            const SizedBox(width: 16),

            // Display Name and Sub
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${userRank.displayName} (You)',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Games: ${userRank.gamesPlayed}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${userRank.totalScore}',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.secondaryContainer, // Sunny Yellow Gold
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'points',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onPrimaryContainer,
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
