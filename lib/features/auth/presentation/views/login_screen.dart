import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Hero Area
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.travel_explore_outlined,
                  size: 100,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title & Tagline
              Text(
                'TravelQuest',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Discover the world through knowledge',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 64),

              // Sign In Card for Hosts
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Host Control Panel',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in with Google to create and manage your quiz rooms.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 14),
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
                              'Cancel Sign In',
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
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.login),
                            const SizedBox(width: 12),
                            Text(
                              'Sign in with Google',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSecondaryContainer,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Player CTA Area
              const Text(
                'Are you a traveler playing a game?',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  context.push('/join-quest');
                },
                child: Text(
                  'Join a Quest Room (No Login)',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.secondary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
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
