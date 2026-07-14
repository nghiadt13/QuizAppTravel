import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/participant.dart';

class PlayerAvatarGrid extends StatelessWidget {
  final List<Participant> participants;
  final String? hostId;

  const PlayerAvatarGrid({
    super.key,
    required this.participants,
    this.hostId,
  });

  String _getEmoji(String id) {
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

  Color _getBackgroundColor(String id) {
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
    if (participants.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 48,
                color: AppColors.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Waiting for players to join...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        final isHost = participant.playerId == hostId;
        final emoji = _getEmoji(participant.avatarId);
        final bg = _getBackgroundColor(participant.avatarId);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: AppColors.background,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bg,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      participant.displayName,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isHost)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryContainer, // Sunny Yellow
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
