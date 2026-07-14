import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../viewmodels/player_setup_view_model.dart';
import '../viewmodels/join_room_view_model.dart';
import '../widgets/pin_input_field.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  String _pinCode = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playerSetupVm = context.read<PlayerSetupViewModel>();
      if (playerSetupVm.displayName == null || playerSetupVm.avatarId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please set up your profile name and avatar before joining a room.'),
            backgroundColor: AppColors.coralOrange,
          ),
        );
        context.replace('/player-setup');
      }
    });
  }

  Future<void> _onJoin() async {
    if (_pinCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit PIN.')),
      );
      return;
    }

    final playerSetupVm = context.read<PlayerSetupViewModel>();
    final joinVm = context.read<JoinRoomViewModel>();

    // Make sure we have the required player parameters
    playerSetupVm.generatePlayerId();

    final room = await joinVm.joinRoom(
      pinCode: _pinCode,
      displayName: playerSetupVm.displayName ?? 'Player',
      avatarId: playerSetupVm.avatarId ?? 'dog',
      playerId: playerSetupVm.playerId!,
    );

    if (room != null && mounted) {
      context.replace('/lobby/${room.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final joinVm = context.watch<JoinRoomViewModel>();
    final playerSetupVm = context.watch<PlayerSetupViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Join a Quest',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home/quests');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Enter Quest PIN 🔑',
                style: AppTextStyles.displayLargeMobile.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Type the 6-digit room code shared by the host to enter the game.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // PIN Box Field
              PinInputField(
                onChanged: (pin) {
                  setState(() {
                    _pinCode = pin;
                  });
                },
                onComplete: _onJoin,
              ),
              const SizedBox(height: 40),

              // Player Info Preview Card
              Card(
                elevation: 0,
                color: AppColors.primaryContainer.withValues(alpha: 0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Playing as: ${playerSetupVm.displayName ?? "No Name"}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/player-setup'),
                        child: Text(
                          'Edit Profile',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.coralOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Error display
              if (joinVm.errorMessage != null) ...[
                Text(
                  joinVm.errorMessage!,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              // Join Button
              ElevatedButton(
                onPressed: joinVm.isLoading ? null : _onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Deep Ocean Blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: joinVm.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Join Quest Room',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Link to Browse
              TextButton(
                onPressed: () => context.push('/browse-quests'),
                child: RichText(
                  text: TextSpan(
                    text: "Don't have a PIN? ",
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
                    children: [
                      TextSpan(
                        text: 'Browse Public Quests',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.coralOrange,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
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
