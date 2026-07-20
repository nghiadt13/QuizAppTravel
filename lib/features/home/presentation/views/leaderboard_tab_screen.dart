import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../quest_room/application/services/i_quest_room_service.dart';
import '../../../quest_room/domain/entities/participant.dart';
import '../../../quest_room/domain/entities/quest_room.dart';
import '../../../quest_room/presentation/viewmodels/player_setup_view_model.dart';

class LeaderboardTabScreen extends StatefulWidget {
  const LeaderboardTabScreen({super.key});

  @override
  State<LeaderboardTabScreen> createState() => _LeaderboardTabScreenState();
}

class _LeaderboardTabScreenState extends State<LeaderboardTabScreen> {
  Future<List<QuestRoom>>? _roomsFuture;
  bool _isLoadingTap = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_roomsFuture == null) {
      _loadRooms();
    }
  }

  void _loadRooms() {
    if (!mounted) return;
    final authVm = context.read<AuthViewModel>();
    final playerSetupVm = context.read<PlayerSetupViewModel>();
    final userId = authVm.currentUser?.uid ?? playerSetupVm.playerId ?? '';
    final isAdmin = authVm.currentUser?.email == 'll.stylish73@gmail.com';

    setState(() {
      _roomsFuture = getIt<IQuestRoomService>().getLeaderboardRoomsForUser(
        userId,
        isAdmin: isAdmin,
      );
    });
  }

  Future<void> _handleRoomTap(
    QuestRoom room,
    String userId,
    bool isAdmin,
  ) async {
    // Admin or Host can view room leaderboard anytime
    if (isAdmin || room.hostId == userId) {
      _showRoomLeaderboardBottomSheet(context, room);
      return;
    }

    setState(() => _isLoadingTap = true);
    try {
      final participants = await getIt<IQuestRoomService>().getParticipants(room.id);
      if (!mounted) return;
      setState(() => _isLoadingTap = false);

      Participant? userParticipant;
      for (final p in participants) {
        if (p.playerId == userId) {
          userParticipant = p;
          break;
        }
      }

      final isFinished = userParticipant != null &&
          (userParticipant.status == ParticipantStatus.finished ||
              room.status == RoomStatus.finished);

      if (isFinished) {
        _showRoomLeaderboardBottomSheet(context, room);
      } else {
        _showNotFinishedDialog(context);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingTap = false);
      _showNotFinishedDialog(context);
    }
  }

  void _showNotFinishedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_clock_rounded, color: AppColors.secondary),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Chưa mở Bảng xếp hạng',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(
          'Bạn cần hoàn thành bài quiz trong phòng này để có thể xem bảng xếp hạng chi tiết của người chơi.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  void _showRoomLeaderboardBottomSheet(BuildContext context, QuestRoom room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RoomLeaderboardBottomSheet(room: room),
    );
  }

  Future<void> _confirmDeleteRoom(QuestRoom room) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Xóa phòng game?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa phòng game "${room.topic}" (PIN: ${room.pinCode}) không? Thao tác này không thể hoàn tác.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa phòng'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await getIt<IQuestRoomService>().deleteRoom(room.id);
        _loadRooms();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa phòng game thành công!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể xóa phòng: $e')),
          );
        }
      }
    }
  }

  Future<void> _confirmEndRoom(QuestRoom room) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.stop_circle_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Text('Dừng thi đấu phòng game?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn dừng phòng game "${room.topic}" và chuyển trạng thái sang "Đã kết thúc"?',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
            ),
            child: const Text('Dừng thi đấu'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await FirebaseFirestore.instance.collection('rooms').doc(room.id).update({
          'status': 'finished',
        });
        _loadRooms();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phòng game đã được chuyển sang trạng thái "Đã kết thúc".')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể dừng phòng: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final playerSetupVm = context.watch<PlayerSetupViewModel>();
    final userId = authVm.currentUser?.uid ?? playerSetupVm.playerId ?? '';
    final isAdmin = authVm.currentUser?.email == 'll.stylish73@gmail.com';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Bảng Xếp Hạng 🏆',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
            fontSize: 19,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadRooms,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async => _loadRooms(),
              child: FutureBuilder<List<QuestRoom>>(
                future: _roomsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                            const SizedBox(height: 16),
                            const Text(
                              'Không thể tải danh sách phòng game.',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadRooms,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final rooms = snapshot.data ?? [];

                  if (rooms.isEmpty) {
                    return _EmptyRoomsState(isAdmin: isAdmin);
                  }

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    children: [
                      _LeaderboardHero(isAdmin: isAdmin),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.meeting_room_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isAdmin
                                  ? 'Danh Sách Phòng Game Admin (${rooms.length})'
                                  : 'Phòng Thi Đấu Đã Tham Gia (${rooms.length})',
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.primary,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...rooms.map(
                        (room) => _RoomCard(
                          room: room,
                          canManage: isAdmin || room.hostId == userId,
                          onTap: () => _handleRoomTap(room, userId, isAdmin),
                          onDelete: () => _confirmDeleteRoom(room),
                          onEndRoom: () => _confirmEndRoom(room),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (_isLoadingTap)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardHero extends StatelessWidget {
  final bool isAdmin;

  const _LeaderboardHero({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF00796B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'XẾP HẠNG THEO PHÒNG GAME',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.9,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isAdmin
                ? 'Quản lý bảng xếp hạng các phòng game'
                : 'Bảng xếp hạng phòng thi đấu đã tham gia',
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            isAdmin
                ? 'Xem thứ hạng và kết quả người chơi trong các phòng game đã khởi tạo.'
                : 'Chọn phòng bạn đã hoàn thành bài quiz để xem bảng xếp hạng chi tiết.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final QuestRoom room;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEndRoom;
  final bool canManage;

  const _RoomCard({
    required this.room,
    required this.onTap,
    this.onDelete,
    this.onEndRoom,
    this.canManage = false,
  });

  String _formatDate(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$h:$min - $d/$m/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = _formatDate(room.createdAt);

    Color statusColor;
    String statusText;
    switch (room.status) {
      case RoomStatus.waiting:
        statusColor = const Color(0xFF3B82F6);
        statusText = 'Chờ người chơi';
        break;
      case RoomStatus.playing:
        statusColor = const Color(0xFFEAB308);
        statusText = 'Đang thi đấu';
        break;
      case RoomStatus.finished:
        statusColor = const Color(0xFF22C55E);
        statusText = 'Đã kết thúc';
        break;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Room Icon Container
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.sports_esports_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              // Room Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'PIN: ${room.pinCode}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      room.topic,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Khởi tạo: $formattedTime',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (canManage)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onSelected: (value) {
                    if (value == 'end' && onEndRoom != null) {
                      onEndRoom!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    if (room.status != RoomStatus.finished && onEndRoom != null)
                      const PopupMenuItem(
                        value: 'end',
                        child: Row(
                          children: [
                            Icon(Icons.stop_circle_outlined, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text('Dừng thi đấu'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Xóa phòng'),
                          ],
                        ),
                      ),
                  ],
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.outline,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRoomsState extends StatelessWidget {
  final bool isAdmin;

  const _EmptyRoomsState({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.14),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.14),
                  AppColors.secondaryContainer.withValues(alpha: 0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              size: 52,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isAdmin ? 'Chưa có phòng game nào' : 'Chưa có phòng thi đấu',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          isAdmin
              ? 'Hãy tạo phòng game công khai mới để mở giải thi đấu cho người chơi nhé!'
              : 'Bạn chưa tham gia phòng thi đấu nào ! Hãy nhập mã PIN để tham gia phòng game và xem bảng xếp hạng !',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.4,
            fontSize: 14.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RoomLeaderboardBottomSheet extends StatelessWidget {
  final QuestRoom room;

  const _RoomLeaderboardBottomSheet({required this.room});

  @override
  Widget build(BuildContext context) {
    final questRoomService = getIt<IQuestRoomService>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'PIN: ${room.pinCode}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                          Text(
                            room.topic,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Bảng Xếp Hạng Người Chơi Trong Phòng',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 24),

          // Participant Leaderboard Stream
          Expanded(
            child: StreamBuilder<List<Participant>>(
              stream: questRoomService.watchParticipants(room.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final participants = snapshot.data ?? [];
                if (participants.isEmpty) {
                  return const Center(
                    child: Text('Chưa có người chơi tham gia phòng này.'),
                  );
                }

                // Sort participants by score descending
                final sorted = List<Participant>.from(participants)
                  ..sort((a, b) => b.score.compareTo(a.score));

                final topThree = sorted.take(3).toList();
                final rest = sorted.length > 3 ? sorted.sublist(3) : <Participant>[];

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      // Top 3 Podium
                      _ParticipantPodium(topThree: topThree),

                      const SizedBox(height: 16),

                      if (rest.isNotEmpty) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10, left: 4),
                            child: Text(
                              'Bảng xếp hạng tiếp theo',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        ...List.generate(rest.length, (index) {
                          final p = rest[index];
                          final rank = index + 4; // Top 4 onwards

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 36,
                                  child: Center(
                                    child: Text(
                                      '#$rank',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.outline,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                AppAvatar(
                                  avatarUrl: p.avatarId,
                                  displayName: p.displayName,
                                  radius: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.displayName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        p.status == ParticipantStatus.finished
                                            ? 'Đã hoàn thành'
                                            : 'Đang thi đấu',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: p.status == ParticipantStatus.finished
                                              ? const Color(0xFF22C55E)
                                              : AppColors.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${p.score} điểm',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantPodium extends StatelessWidget {
  final List<Participant> topThree;

  const _ParticipantPodium({required this.topThree});

  @override
  Widget build(BuildContext context) {
    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place Column (Left)
          if (second != null)
            _buildPodiumColumn(
              context,
              participant: second,
              place: 2,
              height: 90.0,
              color: const Color(0xFFC0C0C0), // Silver
              badge: '🥈',
            )
          else
            const Expanded(child: SizedBox()),

          const SizedBox(width: 8),

          // 1st Place Column (Center - Highest)
          if (first != null)
            _buildPodiumColumn(
              context,
              participant: first,
              place: 1,
              height: 120.0,
              color: const Color(0xFFFFD700), // Gold
              badge: '🥇',
              hasCrown: true,
            )
          else
            const Expanded(child: SizedBox()),

          const SizedBox(width: 8),

          // 3rd Place Column (Right)
          if (third != null)
            _buildPodiumColumn(
              context,
              participant: third,
              place: 3,
              height: 75.0,
              color: const Color(0xFFCD7F32), // Bronze
              badge: '🥉',
            )
          else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn(
    BuildContext context, {
    required Participant participant,
    required int place,
    required double height,
    required Color color,
    required String badge,
    bool hasCrown = false,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar stack with crown/badge
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AppAvatar(
                  avatarUrl: participant.avatarId,
                  displayName: participant.displayName,
                  radius: hasCrown ? 28 : 22,
                ),
              ),
              if (hasCrown)
                const Positioned(
                  top: -20,
                  child: Text('👑', style: TextStyle(fontSize: 22)),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Username
          Text(
            participant.displayName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          // Score
          Text(
            '${participant.score} điểm',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),

          // Podium Pedestal Block
          Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withValues(alpha: 0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  badge,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  'TOP $place',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
