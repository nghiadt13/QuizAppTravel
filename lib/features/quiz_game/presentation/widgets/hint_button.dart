import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HintButton extends StatefulWidget {
  final bool isUsed;
  final VoidCallback onTap;
  final bool disabled;

  const HintButton({
    super.key,
    required this.isUsed,
    required this.onTap,
    this.disabled = false,
  });

  @override
  State<HintButton> createState() => _HintButtonState();
}

class _HintButtonState extends State<HintButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showGlow = !widget.isUsed && !widget.disabled;

    Widget buttonBody = FloatingActionButton.extended(
      onPressed: showGlow ? widget.onTap : null,
      backgroundColor: widget.isUsed
          ? AppColors.surfaceVariant
          : AppColors.secondaryContainer, // Sunny Yellow
      foregroundColor: widget.isUsed ? AppColors.outline : AppColors.onSecondaryContainer,
      elevation: showGlow ? 4.0 : 0.0,
      icon: Icon(
        widget.isUsed ? Icons.lightbulb_outline : Icons.lightbulb,
        color: widget.isUsed ? AppColors.outline : AppColors.secondary,
      ),
      label: Text(
        widget.isUsed ? 'Hint Used (-50)' : 'Use Hint (-50)',
        style: AppTextStyles.labelMedium.copyWith(
          color: widget.isUsed ? AppColors.outline : AppColors.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (showGlow) {
      return AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final glowRadius = 4.0 + _glowController.value * 8.0;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryContainer.withValues(
                    alpha: 0.4 * (1.0 - _glowController.value),
                  ),
                  blurRadius: glowRadius,
                  spreadRadius: glowRadius / 2.0,
                ),
              ],
            ),
            child: child,
          );
        },
        child: buttonBody,
      );
    }

    return buttonBody;
  }
}
