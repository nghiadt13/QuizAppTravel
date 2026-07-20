import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String? displayName;
  final double radius;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.avatarUrl,
    this.displayName,
    this.radius = 20,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = radius * 2;

    // 1. Handle Web URL (e.g. Google photo URL)
    if (avatarUrl != null &&
        (avatarUrl!.startsWith('http://') || avatarUrl!.startsWith('https://'))) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? colors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.network(
            avatarUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackWidget(context, colors);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: SizedBox(
                  width: radius,
                  height: radius,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    // 2. Handle Preset Avatars ('dog', 'cat', 'fox', 'bird', 'rabbit', 'owl', etc.)
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      final emoji = _getEmoji(avatarUrl!);
      final bg = backgroundColor ?? _getAvatarBg(avatarUrl!);
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Text(
          emoji,
          style: TextStyle(fontSize: radius * 1.0),
        ),
      );
    }

    // 3. Fallback for null/empty avatarUrl
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: _buildFallbackWidget(context, colors),
    );
  }

  Widget _buildFallbackWidget(BuildContext context, ColorScheme colors) {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      final firstLetter = displayName!.trim()[0].toUpperCase();
      return Text(
        firstLetter,
        style: TextStyle(
          fontSize: radius * 0.9,
          fontWeight: FontWeight.bold,
          color: colors.primary,
        ),
      );
    }
    return Icon(
      Icons.person,
      size: radius * 1.1,
      color: colors.primary,
    );
  }

  String _getEmoji(String avatarUrl) {
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

  Color _getAvatarBg(String avatarUrl) {
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
        return const Color(0xFFE0F2FE);
    }
  }
}
