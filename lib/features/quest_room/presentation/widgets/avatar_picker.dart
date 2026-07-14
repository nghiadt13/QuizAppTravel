import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/preset_avatar.dart';

class AvatarPicker extends StatelessWidget {
  final List<PresetAvatar> avatars;
  final String? selectedAvatarId;
  final ValueChanged<String> onSelect;

  const AvatarPicker({
    super.key,
    required this.avatars,
    required this.selectedAvatarId,
    required this.onSelect,
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
    if (avatars.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final avatar = avatars[index];
        final isSelected = avatar.id == selectedAvatarId;
        final emoji = _getEmoji(avatar.id);
        final bg = _getBackgroundColor(avatar.id);

        return GestureDetector(
          onTap: () => onSelect(avatar.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.coralOrange : Colors.transparent,
                width: 3.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.coralOrange.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      avatar.label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.coralOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
