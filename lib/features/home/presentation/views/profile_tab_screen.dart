import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../viewmodels/profile_view_model.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      if (authVm.currentUser != null) {
        context.read<ProfileViewModel>().fetchUserRooms(authVm.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final profileVm = context.watch<ProfileViewModel>();
    final colors = Theme.of(context).colorScheme;

    final user = authVm.currentUser;

    if (profileVm.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileVm.errorMessage!),
            backgroundColor: colors.error,
          ),
        );
        profileVm.clearError();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '👤 My Profile',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text('Not logged in.'))
          : RefreshIndicator(
              onRefresh: () async {
                await profileVm.fetchUserRooms(user.uid);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // User Info Header Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: colors.primaryContainer.withValues(alpha: 0.2),
                            backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                                ? Text(
                                    user.displayName.isNotEmpty
                                        ? user.displayName[0].toUpperCase()
                                        : 'H',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          // Name
                          Text(
                            user.displayName,
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          // Email
                          Text(
                            user.email,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          // Member since
                          Text(
                            'Member since ${_formatDate(user.createdAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black38,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Section Header: My Created Rooms
                    Row(
                      children: [
                        const Icon(Icons.meeting_room_outlined, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'My Created Rooms',
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${profileVm.userRooms.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Rooms List
                    if (profileVm.isLoading && profileVm.userRooms.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (profileVm.userRooms.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history_toggle_off_outlined,
                              size: 48,
                              color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No quiz rooms created yet.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Host a new quest to see your active rooms here!',
                              style: TextStyle(color: Colors.black38, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: profileVm.userRooms.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final room = profileVm.userRooms[index];
                          final statusColor = _getStatusColor(room.status.name, colors);

                          return Card(
                            margin: EdgeInsets.zero,
                            color: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                room.topic,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'PIN: ${room.pinCode}',
                                          style: const TextStyle(
                                            fontFamily: 'Courier',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          room.status.name.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Created: ${_formatDate(room.createdAt)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: room.status.name == 'waiting'
                                  ? IconButton(
                                      onPressed: () {
                                        context.push('/lobby/${room.id}');
                                      },
                                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                      color: colors.primary,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 40),

                    // Logout Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text('Are you sure you want to sign out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'Sign Out',
                                  style: TextStyle(color: colors.error),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await authVm.signOut();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out & Exit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.errorContainer,
                        foregroundColor: colors.onErrorContainer,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status, ColorScheme colors) {
    switch (status) {
      case 'waiting':
        return Colors.blue;
      case 'playing':
        return Colors.orange;
      case 'finished':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
