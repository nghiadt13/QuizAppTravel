import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _float1;
  late final Animation<double> _float2;
  late final Animation<double> _rock;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _float1 = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _float2 = Tween<double>(begin: 10.0, end: -10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rock = Tween<double>(begin: -0.06, end: 0.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final colors = Theme.of(context).colorScheme;

    // Show error snackbar if any
    if (viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage!),
            backgroundColor: colors.error,
          ),
        );
        viewModel.clearError();
      });
    }

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // ----------------------------------------------------
          // Background Decorative Elements (Soft Gradient Circles)
          // ----------------------------------------------------
          Positioned(
            left: -80,
            top: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: 0.03),
              ),
            ),
          ),
          Positioned(
            right: -100,
            bottom: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.secondaryContainer.withValues(alpha: 0.05),
              ),
            ),
          ),
          
          // ----------------------------------------------------
          // Background Bubbles Effect (Rising Particles)
          // ----------------------------------------------------
          const Positioned.fill(
            child: AnimatedBubbles(),
          ),

          // ----------------------------------------------------
          // Interactive Animated Floating Elements (Travel/Quiz Theme)
          // ----------------------------------------------------
          // 1. Top-Left: Floating Cloud & Sun
          AnimatedBuilder(
            animation: _float1,
            builder: (context, child) {
              return Positioned(
                left: 30,
                top: 120 + _float1.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wb_sunny_outlined, size: 22, color: Colors.orange.withValues(alpha: 0.3)),
                      const SizedBox(width: 6),
                      Icon(Icons.cloud_outlined, size: 22, color: colors.primary.withValues(alpha: 0.2)),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // 2. Top-Right: Floating & Rocking Paper Airplane
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                right: 45,
                top: 100 + _float2.value,
                child: Transform.rotate(
                  angle: 0.4 + _rock.value,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      size: 24,
                      color: colors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              );
            },
          ),

          // 3. Mid-Left: Floating Compass
          AnimatedBuilder(
            animation: _float2,
            builder: (context, child) {
              return Positioned(
                left: 25,
                bottom: 200 + _float2.value,
                child: Transform.rotate(
                  angle: _rock.value,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.explore_outlined,
                      size: 28,
                      color: colors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              );
            },
          ),

          // 4. Mid-Right: Floating Trophy / Cup
          AnimatedBuilder(
            animation: _float1,
            builder: (context, child) {
              return Positioned(
                right: 35,
                bottom: 160 + _float1.value,
                child: Transform.rotate(
                  angle: -0.1 + _rock.value,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.emoji_events_outlined,
                      size: 26,
                      color: colors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              );
            },
          ),

          // ----------------------------------------------------
          // Main Interactive Interface
          // ----------------------------------------------------
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo Hero Area
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.08),
                              width: 2,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.03),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Icon(
                                Icons.compass_calibration_outlined,
                                size: 80,
                                color: colors.primary.withValues(alpha: 0.12),
                              ),
                              Icon(
                                Icons.lightbulb_rounded,
                                size: 48,
                                color: colors.primary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title & Subtitle Area
                        Text(
                          'QuizMaster',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Travel edition badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.public, size: 14, color: colors.primary),
                              const SizedBox(width: 4),
                              Text(
                                'BẢN DU LỊCH',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Kiểm tra kiến thức, thách thức bạn bè',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 48),

                        // Sign In Card for Hosts
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.08),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.04),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'BẢNG ĐIỀU KHIỂN CHỦ PHÒNG',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Đăng Nhập & Cùng Chơi',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Đăng nhập bằng Google để tham gia trò chơi, tự tạo bộ câu hỏi và mời bạn bè cùng chơi.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (viewModel.isLoading)
                                Column(
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 16),
                                    TextButton(
                                      onPressed: () {
                                        viewModel.resetLoadingState();
                                      },
                                      child: Text(
                                        'Hủy Đăng Nhập',
                                        style: TextStyle(
                                          color: colors.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                ElevatedButton(
                                  onPressed: () async {
                                    await viewModel.signInWithGoogle();
                                    if (context.mounted && viewModel.isAuthenticated) {
                                      context.go('/home/quests');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.secondaryContainer,
                                    foregroundColor: colors.onSecondaryContainer,
                                    minimumSize: const Size(double.infinity, 54),
                                    elevation: 2,
                                    shadowColor: colors.secondary.withValues(alpha: 0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.network(
                                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                                          width: 18,
                                          height: 18,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.login_rounded,
                                              size: 18,
                                              color: colors.primary,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          'Đăng nhập bằng Google',
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colors.onSecondaryContainer,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Player Area (Action Card instead of simple link)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.tertiary.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colors.tertiary.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Sẵn Sàng Trải Nghiệm? 🎮',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: colors.tertiary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tham gia ngay vào phòng game có sẵn để chơi mà không cần tài khoản.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () {
                                  context.push('/join-quest');
                                },
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text(
                                  'Vào Phòng Game',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.tertiary,
                                  side: BorderSide(color: colors.tertiary.withValues(alpha: 0.3)),
                                  minimumSize: const Size(double.infinity, 44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// Animated Bubbles Component (Rising Particles)
// ----------------------------------------------------
class AnimatedBubbles extends StatefulWidget {
  const AnimatedBubbles({super.key});

  @override
  State<AnimatedBubbles> createState() => _AnimatedBubblesState();
}

class _AnimatedBubblesState extends State<AnimatedBubbles> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Bubble> _bubbles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Initialize 20 bubbles with random values
    for (int i = 0; i < 20; i++) {
      _bubbles.add(Bubble(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 1.2, // Spread out vertically
        size: _random.nextDouble() * 8 + 4, // size 4 to 12
        speed: _random.nextDouble() * 0.0006 + 0.0003, // Slower float speed
        opacity: _random.nextDouble() * 0.12 + 0.04, // Translucent opacity
        swaySpeed: _random.nextDouble() * 0.8 + 0.4, // Slower swaying motion
        swayWidth: _random.nextDouble() * 8 + 2, // Gentler swaying width
      ));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_updateBubbles)
     ..repeat();
  }

  void _updateBubbles() {
    if (!mounted) return;
    setState(() {
      for (var bubble in _bubbles) {
        bubble.y -= bubble.speed;
        if (bubble.y < -0.1) {
          // Reset to bottom once it floats out of view
          bubble.y = 1.1;
          bubble.x = _random.nextDouble();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubblePainter(bubbles: _bubbles, colors: Theme.of(context).colorScheme),
      child: const SizedBox.expand(),
    );
  }
}

class Bubble {
  double x; // Horizontal percentage (0.0 to 1.0)
  double y; // Vertical percentage (0.0 to 1.0)
  final double size;
  final double speed;
  final double opacity;
  final double swaySpeed;
  final double swayWidth;
  double time = 0.0;

  Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.swaySpeed,
    required this.swayWidth,
  });
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final ColorScheme colors;

  BubblePainter({required this.bubbles, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var bubble in bubbles) {
      // Sway left/right based on sine wave
      bubble.time += 0.016; // Simulate delta time
      final double sway = sin(bubble.time * bubble.swaySpeed) * bubble.swayWidth;
      
      final double actualX = bubble.x * size.width + sway;
      final double actualY = bubble.y * size.height;

      // Draw bubble base
      paint.color = colors.primary.withValues(alpha: bubble.opacity);
      canvas.drawCircle(Offset(actualX, actualY), bubble.size, paint);

      // Draw bubble specular highlight (reflecting light on top-left)
      paint.color = Colors.white.withValues(alpha: bubble.opacity * 1.8);
      canvas.drawCircle(
        Offset(actualX - bubble.size * 0.3, actualY - bubble.size * 0.3),
        bubble.size * 0.22,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

