import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RoomCodeDisplay extends StatelessWidget {
  final String pinCode;

  const RoomCodeDisplay({
    super.key,
    required this.pinCode,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: pinCode));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Room PIN $pinCode copied to clipboard!'),
            ),
          ],
        ),
        backgroundColor: AppColors.tertiaryContainer, // Lush Green
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: AppColors.primary, // Deep Ocean Blue container
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ROOM CODE PIN',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  pinCode,
                  style: AppTextStyles.displayLargeMobile.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy, color: Colors.white),
                  tooltip: 'Copy Code',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
