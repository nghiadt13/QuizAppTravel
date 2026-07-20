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

  @override
  Widget build(BuildContext context) {
    if (avatars.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width < 360
            ? 2
            : width < 620
            ? 3
            : width < 860
            ? 4
            : 6;
        final tileHeight = width < 360
            ? 136.0
            : width < 620
            ? 146.0
            : 154.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: tileHeight,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: avatars.length,
          itemBuilder: (context, index) {
            final avatar = avatars[index];
            return _AnimatedAvatarTile(
              avatar: avatar,
              index: index,
              isSelected: avatar.id == selectedAvatarId,
              onTap: () => onSelect(avatar.id),
              compact: width < 420,
            );
          },
        );
      },
    );
  }
}

class _AnimatedAvatarTile extends StatefulWidget {
  final PresetAvatar avatar;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  const _AnimatedAvatarTile({
    required this.avatar,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.compact,
  });

  @override
  State<_AnimatedAvatarTile> createState() => _AnimatedAvatarTileState();
}

class _AnimatedAvatarTileState extends State<_AnimatedAvatarTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200 + (widget.index % 4) * 180),
    )..repeat(reverse: true);
    _floatAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      case 'panda':
        return '🐼';
      case 'bear':
        return '🐻';
      case 'koala':
        return '🐨';
      case 'penguin':
        return '🐧';
      case 'monkey':
        return '🐵';
      case 'tiger':
        return '🐯';
      default:
        return '🙂';
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
      case 'panda':
        return const Color(0xFFF5F5F5);
      case 'bear':
        return const Color(0xFFFFF8E1);
      case 'koala':
        return const Color(0xFFE0F2F1);
      case 'penguin':
        return const Color(0xFFE1F5FE);
      case 'monkey':
        return const Color(0xFFFFF1E6);
      case 'tiger':
        return const Color(0xFFFFE0B2);
      default:
        return AppColors.surfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _getEmoji(widget.avatar.id);
    final bg = _getBackgroundColor(widget.avatar.id);
    final avatarSize = widget.compact ? 64.0 : 74.0;
    final emojiSize = widget.compact ? 38.0 : 44.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          final floatValue = _floatAnimation.value;
          final yOffset = widget.isSelected ? -4.0 : -2.5 * floatValue;
          final scale = widget.isSelected ? 1.06 : 1.0 + (0.025 * floatValue);

          return Transform.translate(
            offset: Offset(0, yOffset),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isSelected ? AppColors.coralOrange : Colors.white,
              width: widget.isSelected ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? AppColors.coralOrange.withValues(alpha: 0.28)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: widget.isSelected ? 16 : 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: avatarSize,
                      height: avatarSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        shape: BoxShape.circle,
                      ),
                      child: Text(emoji, style: TextStyle(fontSize: emojiSize)),
                    ),
                    SizedBox(height: widget.compact ? 8 : 10),
                    Text(
                      widget.avatar.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.coralOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 15,
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
