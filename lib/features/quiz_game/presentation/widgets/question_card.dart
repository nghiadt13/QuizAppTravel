import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/quiz_question.dart';

class QuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final int currentQuestionIndex;
  final int totalQuestions;

  const QuestionCard({
    super.key,
    required this.question,
    required this.currentQuestionIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Question Progress Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'QUESTION ${currentQuestionIndex + 1} OF $totalQuestions',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                // Tiny travel indicator
                const Icon(
                  Icons.card_travel_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question Image with Location Tag Overlay (if exists)
            if (question.imageUrl != null && question.imageUrl!.isNotEmpty) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceVariant,
                      ),
                      child: Image.network(
                        question.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 40,
                              color: AppColors.outline,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Location Tag Overlay
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Quiz Landmark',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Question Text
            Text(
              question.text,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
