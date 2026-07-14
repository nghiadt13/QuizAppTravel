import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../viewmodels/create_room_view_model.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _topicController.addListener(() {
      context.read<CreateRoomViewModel>().setTopic(_topicController.text);
    });
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _onCreateRoom() async {
    final authVm = context.read<AuthViewModel>();
    final hostId = authVm.currentUser?.uid;

    if (hostId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Host is not logged in. Please sign in first.')),
      );
      context.go('/login');
      return;
    }

    final createVm = context.read<CreateRoomViewModel>();
    final room = await createVm.createRoom(hostId);
    if (room != null && mounted) {
      context.replace('/lobby/${room.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final createVm = context.watch<CreateRoomViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Host a Quest',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Launch a New Quest! 🚀',
                style: AppTextStyles.displayLargeMobile.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a topic, configure room options, and invite your friends.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Topic Input
              Text(
                'QUEST TOPIC',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _topicController,
                decoration: InputDecoration(
                  hintText: 'Enter custom topic name...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.edit_road_outlined, color: AppColors.primary),
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
              const SizedBox(height: 24),

              // Preset Topics Grid / Wrap
              Text(
                'OR CHOOSE A POPULAR TOPIC',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: createVm.presetTopics.map((topic) {
                  final isSelected = createVm.topic == topic;
                  return ChoiceChip(
                    label: Text(topic),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _topicController.text = topic;
                        createVm.setTopic(topic);
                      }
                    },
                    selectedColor: AppColors.primaryContainer,
                    backgroundColor: Colors.white,
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : AppColors.outlineVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Public Toggle
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.outlineVariant),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Public Room',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  subtitle: Text(
                    'Allows other players to see and join your room from public lobby listings.',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  value: createVm.isPublic,
                  onChanged: createVm.toggleIsPublic,
                  activeThumbColor: AppColors.tertiaryContainer, // Lush Green
                  inactiveTrackColor: AppColors.surfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Error notification
              if (createVm.errorMessage != null) ...[
                Text(
                  createVm.errorMessage!,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              // Create button
              ElevatedButton(
                onPressed: createVm.isLoading ? null : _onCreateRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Deep Ocean Blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: createVm.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Create Room & Open Lobby',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
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
