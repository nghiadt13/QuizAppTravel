import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SeasonRewardBanner extends StatelessWidget {
  final DateTime? seasonEndDate;
  final String? rewardDescription;

  const SeasonRewardBanner({
    super.key,
    required this.seasonEndDate,
    required this.rewardDescription,
  });

  String _getRemainingTimeText(DateTime? endDate) {
    if (endDate == null) return 'Ending soon!';
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) return 'Season ended';

    final days = difference.inDays;
    final hours = difference.inHours % 24;

    if (days > 0) {
      return '${days}d ${hours}h left';
    } else if (hours > 0) {
      final minutes = difference.inMinutes % 60;
      return '${hours}h ${minutes}m left';
    } else {
      final minutes = difference.inMinutes;
      return '${minutes}m left!';
    }
  }

  void _showRewardInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Season Rewards 🎁'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Join the quest race! Increase your rank to claim exclusive real-world travel rewards.',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rewardDescription ?? 'Top 10 players get discount flight/hotel codes!',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingTime = _getRemainingTimeText(seasonEndDate);
    final desc = rewardDescription ?? 'Top players receive exclusive travel discount codes.';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.secondaryContainer, width: 1.5),
      ),
      color: AppColors.secondaryContainer.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () => _showRewardInfoDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer, // Sunny Yellow
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.campaign,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),

              // Title and Sub
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Season Ends: $remainingTime',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Info Icon indicator
              const Icon(
                Icons.chevron_right,
                color: AppColors.secondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
