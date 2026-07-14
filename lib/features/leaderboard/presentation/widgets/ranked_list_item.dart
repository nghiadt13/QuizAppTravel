import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/leaderboard_entry.dart';

class RankedListItem extends StatelessWidget {
  final LeaderboardEntry entry;

  const RankedListItem({
    super.key,
    required this.entry,
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
    final emoji = _getEmoji(entry.avatarUrl);
    final bg = _getAvatarBg(entry.avatarUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Text(
              '#${entry.rank}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),

          // Player Name and Game count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Games: ${entry.gamesPlayed}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),

          // Score
          Text(
            '${entry.totalScore} pts',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
