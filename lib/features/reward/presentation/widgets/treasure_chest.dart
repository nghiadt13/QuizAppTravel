import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TreasureChest extends StatefulWidget {
  final bool isShaking;
  final bool isOpened;
  final VoidCallback onTap;

  const TreasureChest({
    super.key,
    required this.isShaking,
    required this.isOpened,
    required this.onTap,
  });

  @override
  State<TreasureChest> createState() => _TreasureChestState();
}

class _TreasureChestState extends State<TreasureChest>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  double _getShakeOffset() {
    if (!widget.isShaking) return 0.0;
    // Oscillate between -6.0 and 6.0 based on a random factor or simple alternating pattern
    final random = Random();
    return (random.nextBool() ? 1 : -1) * (4.0 + random.nextDouble() * 4.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isOpened ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          final floatOffset = widget.isOpened ? 0.0 : _floatAnimation.value;
          final shakeOffset = _getShakeOffset();

          return Transform.translate(
            offset: Offset(shakeOffset, floatOffset),
            child: child,
          );
        },
        child: Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Open Chest Glow
                if (widget.isOpened)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.secondaryContainer.withValues(alpha: 0.8),
                          AppColors.secondaryContainer.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                // Chest Body (Wood and Gold bands)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lid
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 400),
                      turns: widget.isOpened ? -0.15 : 0.0,
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        width: 120,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Color(0xFF5D4037), // Dark brown wood
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Gold Trim Left
                            Positioned(
                              left: 20,
                              top: 0,
                              bottom: 0,
                              width: 10,
                              child: Container(color: AppColors.secondaryContainer),
                            ),
                            // Gold Trim Right
                            Positioned(
                              right: 20,
                              top: 0,
                              bottom: 0,
                              width: 10,
                              child: Container(color: AppColors.secondaryContainer),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Base
                    Container(
                      width: 120,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4E342E), // Deeper brown wood
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          // Gold bands on base
                          Positioned(
                            left: 20,
                            top: 0,
                            bottom: 0,
                            width: 10,
                            child: Container(color: AppColors.secondaryContainer),
                          ),
                          Positioned(
                            right: 20,
                            top: 0,
                            bottom: 0,
                            width: 10,
                            child: Container(color: AppColors.secondaryContainer),
                          ),
                          // Lock
                          Positioned(
                            top: -10,
                            child: Container(
                              width: 24,
                              height: 30,
                              decoration: BoxDecoration(
                                color: widget.isOpened ? Colors.transparent : AppColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF725300), width: 2),
                              ),
                              child: widget.isOpened
                                  ? null
                                  : const Icon(
                                      Icons.lock,
                                      size: 14,
                                      color: Color(0xFF725300),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
