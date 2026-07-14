import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class QuestsTabScreen extends StatelessWidget {
  const QuestsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '🗺️ Quests & Adventures',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.explore_outlined,
                size: 96,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Explore Quests',
                style: AppTextStyles.displayLargeMobile.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Host a multiplayer travel quiz room, browse open lobbies, or join a friend\'s quest via PIN code.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 40),

              // Button 1: Host Room
              ElevatedButton.icon(
                onPressed: () => context.push('/create-room'),
                icon: const Icon(Icons.add_box_outlined),
                label: const Text('Host a New Quest'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 16),

              // Button 2: Join via PIN
              ElevatedButton.icon(
                onPressed: () => context.push('/player-setup'),
                icon: const Icon(Icons.dialpad),
                label: const Text('Join via Room PIN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryContainer, // Sunny Yellow
                  foregroundColor: AppColors.onSecondaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 16),

              // Button 3: Browse Public Lobbies
              OutlinedButton.icon(
                onPressed: () => context.push('/browse-quests'),
                icon: const Icon(Icons.public),
                label: const Text('Browse Public Quests'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
