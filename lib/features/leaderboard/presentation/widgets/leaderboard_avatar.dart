import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LeaderboardAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  final double fontSize;
  final Color? borderColor;
  final double borderWidth;

  const LeaderboardAvatar({
    super.key,
    required this.avatarUrl,
    this.size = 40,
    this.fontSize = 22,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = avatarUrl;
    final isNetworkAvatar =
        avatar != null &&
        (avatar.startsWith('http://') || avatar.startsWith('https://'));

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _getAvatarBg(avatar),
        shape: BoxShape.circle,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: isNetworkAvatar
          ? Image.network(
              avatar,
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorBuilder: (context, error, stackTrace) =>
                  Text(_getEmoji(avatar), style: TextStyle(fontSize: fontSize)),
            )
          : Text(_getEmoji(avatar), style: TextStyle(fontSize: fontSize)),
    );
  }

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
}
