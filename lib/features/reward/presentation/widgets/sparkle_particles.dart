import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SparkleParticles extends StatefulWidget {
  final bool play;

  const SparkleParticles({
    super.key,
    required this.play,
  });

  @override
  State<SparkleParticles> createState() => _SparkleParticlesState();
}

class _SparkleParticlesState extends State<SparkleParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ParticleModel> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    if (widget.play) {
      _generateParticles();
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant SparkleParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      _generateParticles();
      _controller.reset();
      _controller.forward();
    }
  }

  void _generateParticles() {
    _particles.clear();
    final random = Random();
    for (int i = 0; i < 30; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 80.0 + random.nextDouble() * 120.0;
      final size = 3.0 + random.nextDouble() * 5.0;
      final color = random.nextBool() ? AppColors.secondaryContainer : Colors.white;
      _particles.add(ParticleModel(
        angle: angle,
        speed: speed,
        size: size,
        color: color,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: ParticlesPainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class ParticleModel {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  ParticleModel({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class ParticlesPainter extends CustomPainter {
  final List<ParticleModel> particles;
  final double progress;

  ParticlesPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    for (final p in particles) {
      final distance = p.speed * progress;
      final x = center.dx + cos(p.angle) * distance;
      final y = center.dy + sin(p.angle) * distance;

      // Fade out particles near the end of progress
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      paint.color = p.color.withValues(alpha: opacity);

      canvas.drawCircle(Offset(x, y), p.size * (1.0 - progress / 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
