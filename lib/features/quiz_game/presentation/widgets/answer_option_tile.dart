import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AnswerOptionTile extends StatelessWidget {
  final String optionText;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool hasBeenAnswered;
  final bool isEliminated;
  final VoidCallback onTap;

  const AnswerOptionTile({
    super.key,
    required this.optionText,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.hasBeenAnswered,
    required this.isEliminated,
    required this.onTap,
  });

  String _getOptionLetter(int index) {
    switch (index) {
      case 0:
        return 'A';
      case 1:
        return 'B';
      case 2:
        return 'C';
      case 3:
        return 'D';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEliminated) {
      return const SizedBox.shrink(); // Hide eliminated options or render disabled
    }

    Color backgroundColor = Colors.white;
    Color borderColor = AppColors.outlineVariant;
    Color textColor = AppColors.primary;
    Color letterBgColor = AppColors.primaryContainer.withValues(alpha: 0.1);
    Color letterTextColor = AppColors.primary;

    if (hasBeenAnswered) {
      if (isCorrect) {
        // Highlight correct option in Lush Green
        backgroundColor = const Color(0xFFE8F5E9); // Soft Green
        borderColor = const Color(0xFF4CAF50);
        textColor = const Color(0xFF2E7D32);
        letterBgColor = const Color(0xFF4CAF50);
        letterTextColor = Colors.white;
      } else if (isSelected) {
        // Highlight chosen incorrect option in Coral Orange
        backgroundColor = const Color(0xFFFFF3E0); // Soft Orange
        borderColor = AppColors.coralOrange;
        textColor = const Color(0xFFE65100);
        letterBgColor = AppColors.coralOrange;
        letterTextColor = Colors.white;
      } else {
        backgroundColor = Colors.white.withValues(alpha: 0.6);
        borderColor = AppColors.outlineVariant.withValues(alpha: 0.5);
        textColor = AppColors.primary.withValues(alpha: 0.5);
      }
    } else if (isSelected) {
      // Highlight selected before confirm
      backgroundColor = AppColors.primaryContainer.withValues(alpha: 0.08);
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
      letterBgColor = AppColors.primary;
      letterTextColor = Colors.white;
    }

    final letter = _getOptionLetter(index);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: hasBeenAnswered ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isSelected || (hasBeenAnswered && isCorrect) ? 2.0 : 1.5,
              ),
              boxShadow: isSelected || (hasBeenAnswered && isCorrect)
                  ? [
                      BoxShadow(
                        color: borderColor.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Option Letter Badge
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: letterBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    letter,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: letterTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Option Text
                Expanded(
                  child: Text(
                    optionText,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: textColor,
                      fontWeight: isSelected || (hasBeenAnswered && isCorrect)
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
