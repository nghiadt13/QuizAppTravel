import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ActionControlBar extends StatelessWidget {
  final String roomStatus;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onEnd;

  const ActionControlBar({
    super.key,
    required this.roomStatus,
    required this.onPause,
    required this.onResume,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaying = roomStatus == 'playing';
    final isPaused = roomStatus == 'paused';
    final isFinished = roomStatus == 'finished';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pause / Resume Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isFinished
                  ? null
                  : (isPlaying ? onPause : onResume),
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: isFinished ? AppColors.outline : Colors.white,
              ),
              label: Text(
                isFinished
                    ? 'Đã kết thúc'
                    : (isPlaying ? 'Tạm dừng' : 'Tiếp tục'),
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isFinished ? AppColors.outline : Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPaused
                    ? AppColors.tertiaryContainer // Lush Green for resume
                    : AppColors.secondaryContainer, // Sunny Yellow/Orange for pause
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // End Game Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isFinished ? null : onEnd,
              icon: Icon(
                Icons.stop_circle_outlined,
                color: isFinished ? AppColors.outline : AppColors.error,
              ),
              label: Text(
                'Kết thúc',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isFinished ? AppColors.outline : AppColors.error,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isFinished ? AppColors.outlineVariant : AppColors.error,
                  width: 2,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
