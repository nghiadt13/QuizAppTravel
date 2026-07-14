import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CountdownTimer extends StatefulWidget {
  final int timeRemaining;
  final int totalTime;

  const CountdownTimer({
    super.key,
    required this.timeRemaining,
    required this.totalTime,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getColor(double ratio) {
    if (ratio > 0.5) {
      return AppColors.tertiaryContainer; // Lush Green
    } else if (ratio > 0.25) {
      return AppColors.secondaryContainer; // Sunny Yellow
    } else {
      return AppColors.error; // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.totalTime > 0
        ? (widget.timeRemaining / widget.totalTime).clamp(0.0, 1.0)
        : 0.0;
    final color = _getColor(ratio);
    final isCritical = widget.timeRemaining <= 5 && widget.timeRemaining > 0;

    Widget timerWidget = Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: isCritical ? color.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05),
            blurRadius: isCritical ? 12.0 : 6.0,
            spreadRadius: isCritical ? 4.0 : 0.0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: ratio,
              strokeWidth: 6.0,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            '${widget.timeRemaining}',
            style: AppTextStyles.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    if (isCritical) {
      return ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.15).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        ),
        child: timerWidget,
      );
    }

    return timerWidget;
  }
}
