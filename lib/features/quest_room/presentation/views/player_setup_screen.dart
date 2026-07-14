import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../viewmodels/player_setup_view_model.dart';
import '../widgets/avatar_picker.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<PlayerSetupViewModel>();
      vm.loadAvatars();
      if (vm.displayName != null) {
        _nameController.text = vm.displayName!;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final vm = context.read<PlayerSetupViewModel>();
    vm.setDisplayName(_nameController.text);
    
    if (vm.validate()) {
      context.push('/join-quest');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Player Setup',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<PlayerSetupViewModel>(
        builder: (context, vm, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Set Up Your Profile 🧭',
                    style: AppTextStyles.displayLargeMobile.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you want to be displayed in the lobby and pick an avatar.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Name Field
                  Text(
                    'DISPLAY NAME',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter nickname...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  
                  // Avatar Pick
                  Text(
                    'CHOOSE AVATAR',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (vm.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    AvatarPicker(
                      avatars: vm.avatars,
                      selectedAvatarId: vm.avatarId,
                      onSelect: vm.selectAvatar,
                    ),
                  ],
                  const SizedBox(height: 32),
                  
                  // Error message
                  if (vm.errorMessage != null) ...[
                    Text(
                      vm.errorMessage!,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Continue Button
                  ElevatedButton(
                    onPressed: _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryContainer, // Sunny Yellow
                      foregroundColor: AppColors.onSecondaryContainer,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Save & Continue',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
