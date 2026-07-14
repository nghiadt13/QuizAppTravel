import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/leaderboard_entry.dart';

class UserStickyCard extends StatelessWidget {
  final LeaderboardEntry userRank;

  const UserStickyCard({
    super.key,
    required this.userRank,
  });

  String _getEmoji(String? avatarUrl) {
    if (avatarUrl == null) return '👤';
    switch (avatarUrl.toLowerCase()) {
      case 'dog':
        return '🐶';
      case 'cat':
        return '🐱';
      case 'bird':
        return '🐦';
      case 'rabbit':
        return '🐰';
      case 'fox':
        return '🦊';
      case 'owl':
        return '🦉';
      default:
        return '👤';
    }
  }

  Color _getAvatarBg(String? avatarUrl) {
    if (avatarUrl == null) return AppColors.surfaceVariant;
    switch (avatarUrl.toLowerCase()) {
      case 'dog':
        return const Color(0xFFFFECE0);
      case 'cat':
        return const Color(0xFFE8F5E9);
      case 'bird':
        return const Color(0xFFE3F2FD);
      case 'rabbit':
        return const Color(0xFFF3E5F5);
      case 'fox':
        return const Color(0xFFFFF3E0);
      case 'owl':
        return const Color(0xFFECEFF1);
      default:
        return AppColors.surfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _getEmoji(userRank.avatarUrl);
    final bg = _getAvatarBg(userRank.avatarUrl);

    return Card(
      elevation: 4,
      shadowColor: AppColors.primaryContainer.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
              ),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
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
