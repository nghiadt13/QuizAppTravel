import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/leaderboard_entry.dart';

class TopThreePodium extends StatelessWidget {
  final List<LeaderboardEntry> topThree;

  const TopThreePodium({
    super.key,
    required this.topThree,
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
    // Make sure we have 3 slots populated (even if dummy/empty)
    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place Column
          if (second != null)
            _buildPodiumColumn(
              context,
              entry: second,
              place: 2,
              height: 100.0,
              color: const Color(0xFFCFD8DC), // Silver color
            ),
          const SizedBox(width: 12),

          // 1st Place Column
          if (first != null)
            _buildPodiumColumn(
              context,
              entry: first,
              place: 1,
              height: 140.0,
              color: AppColors.secondaryContainer, // Gold color
              hasCrown: true,
            ),
          const SizedBox(width: 12),

          // 3rd Place Column
          if (third != null)
            _buildPodiumColumn(
              context,
              entry: third,
              place: 3,
              height: 80.0,
              color: const Color(0xFFFFCC80), // Bronze color
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn(
    BuildContext context, {
    required LeaderboardEntry entry,
    required int place,
    required double height,
    required Color color,
    bool hasCrown = false,
  }) {
    final emoji = _getEmoji(entry.avatarUrl);
    final bg = _getAvatarBg(entry.avatarUrl);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown / Avatar stack
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Avatar
              Container(
                width: hasCrown ? 64 : 52,
                height: hasCrown ? 64 : 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: 3,
                  ),
                ),
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: hasCrown ? 36 : 28),
                ),
              ),
              // Crown Overlay for 1st
              if (hasCrown)
                const Positioned(
                  top: -24,
                  child: Text(
                    '👑',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Username
          Text(
            entry.displayName,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          // Score
          Text(
            '${entry.totalScore} pts',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Podium Pedestal Block
          Container(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '$place',
              style: AppTextStyles.displayLargeMobile.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
