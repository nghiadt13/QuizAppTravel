import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RoomCodeDisplay extends StatefulWidget {
  final String pinCode;

  const RoomCodeDisplay({
    super.key,
    required this.pinCode,
  });

  @override
  State<RoomCodeDisplay> createState() => _RoomCodeDisplayState();
}

class _RoomCodeDisplayState extends State<RoomCodeDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.pinCode));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Mã PIN phòng ${widget.pinCode} đã được sao chép!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.tertiaryContainer,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _glowAnimation.value * 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: AppColors.secondaryContainer.withValues(alpha: _glowAnimation.value * 0.15),
                blurRadius: 40,
                offset: const Offset(0, 4),
                spreadRadius: -4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    Color(0xFF003847),
                    AppColors.primaryContainer,
                  ],
                ),
              ),
              child: CustomPaint(
                painter: _PinBackgroundPainter(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Label with decorative elements
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.vpn_key_rounded,
                            color: AppColors.onPrimaryContainer.withValues(alpha: 0.8),
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'MÃ PIN PHÒNG',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onPrimaryContainer.withValues(alpha: 0.9),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.vpn_key_rounded,
                            color: AppColors.onPrimaryContainer.withValues(alpha: 0.8),
                            size: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // PIN Display
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // PIN digits with spacing
                            ...List.generate(widget.pinCode.length, (index) {
                              final digit = widget.pinCode[index];

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Add gap between groups (3 + 3)
                                  if (index == 3) const SizedBox(width: 10),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 32,
                                    height: 42,
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      digit,
                                      style: AppTextStyles.headlineMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                            const SizedBox(width: 10),
                            // Copy button
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: Material(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () => _copyToClipboard(context),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.copy_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Share hint
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share_rounded,
                            color: AppColors.onPrimaryContainer.withValues(alpha: 0.6),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Chia sẻ mã này với bạn bè',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.onPrimaryContainer.withValues(alpha: 0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PinBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Decorative circles
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.2),
      30,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.7),
      20,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.95, size.height * 0.15),
      15,
      paint,
    );

    // Decorative dots
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.15 + i * 0.18), size.height * 0.9),
        3,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
