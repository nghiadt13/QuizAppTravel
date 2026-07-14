import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/player_live_status.dart';

class PlayerStatusCard extends StatelessWidget {
  final PlayerLiveStatus status;

  const PlayerStatusCard({
    super.key,
    required this.status,
  });

  String _getEmoji(String? id) {
    if (id == null) return '👤';
    switch (id.toLowerCase()) {
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

  Color _getAvatarBgColor(String? id) {
    if (id == null) return AppColors.surfaceVariant;
    switch (id.toLowerCase()) {
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
    final isFinished = status.status == PlayerGameStatus.finished;
    final emoji = _getEmoji(status.avatarId);
    final bg = _getAvatarBgColor(status.avatarId);

    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isFinished ? AppColors.tertiaryContainer : AppColors.outlineVariant,
          width: isFinished ? 2.0 : 1.0,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
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
            const SizedBox(width: 12),

            // Player details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.displayName,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 14,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Q: ${status.currentQuestionIndex}/${status.totalQuestions}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.star_outline,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${status.score}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isFinished
                    ? AppColors.tertiaryContainer.withValues(alpha: 0.1)
                    : AppColors.secondaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isFinished ? 'Finished' : 'Playing',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isFinished ? AppColors.tertiaryContainer : AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
