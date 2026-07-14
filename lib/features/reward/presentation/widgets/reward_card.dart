import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/travel_reward.dart';

class RewardCard extends StatelessWidget {
  final TravelReward reward;

  const RewardCard({
    super.key,
    required this.reward,
  });

  String _getRewardIcon(RewardType type) {
    switch (type) {
      case RewardType.voucher:
        return '🎫';
      case RewardType.badge:
        return '🏅';
      case RewardType.travelCoins:
        return '🪙';
    }
  }

  Color _getStampColor(RewardType type) {
    switch (type) {
      case RewardType.voucher:
        return AppColors.coralOrange;
      case RewardType.badge:
        return AppColors.primary;
      case RewardType.travelCoins:
        return AppColors.secondaryContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stampIcon = _getRewardIcon(reward.type);
    final stampColor = _getStampColor(reward.type);

    return Card(
      elevation: 6,
      shadowColor: AppColors.primary.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: const Color(0xFFFFFDF9), // Eggshell vintage background
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFEFEBE9), // Soft sepia border
            width: 2.0,
          ),
        ),
        child: Stack(
          children: [
            // Passport Stamp Grid Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                  ),
                  itemBuilder: (context, index) => const Icon(Icons.flight_takeoff, size: 16),
                ),
              ),
            ),

            // Card details
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top border stamp notches
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    11,
                    (index) => Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Stamped Badge Visual
                Transform.rotate(
                  angle: -0.05, // Slightly tilted stamp
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: stampColor.withValues(alpha: 0.8),
                        width: 4,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Text(
                      stampIcon,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  reward.title,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    reward.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),

                // Vintage "APPROVED" circular stamp print
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.withValues(alpha: 0.6), width: 2.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'CLAIM APPROVED',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.red.withValues(alpha: 0.6),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
