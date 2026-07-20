import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../quest_room/application/services/i_quest_room_service.dart';
import '../../../quest_room/domain/entities/participant.dart';
import '../../../quest_room/domain/entities/quest_room.dart';

class LiveMonitoringScreen extends StatefulWidget {
  final String roomId;
  const LiveMonitoringScreen({super.key, required this.roomId});

  @override
  State<LiveMonitoringScreen> createState() => _LiveMonitoringScreenState();
}

class _LiveMonitoringScreenState extends State<LiveMonitoringScreen> {
  final _questRoomService = getIt<IQuestRoomService>();

  Future<void> _endRoom(BuildContext context, String topic) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.stop_circle_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Text('Dừng thi đấu?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Chuyển trạng thái phòng "$topic" sang "Đã kết thúc"?'),
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

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .update({'status': 'finished'});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã dừng thi đấu phòng game!')),
        );
      }
    }
  }

  Future<void> _deleteRoom(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Xóa phòng game?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Bạn có chắc chắn muốn xóa phòng game này không? Thao tác không thể hoàn tác.'),
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

    if (confirm == true && context.mounted) {
      await _questRoomService.deleteRoom(widget.roomId);
      if (context.mounted) {
        context.go('/home/quests');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Modern Dark Slate
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.go('/home/quests'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 10),
                  SizedBox(width: 6),
                  Text(
                    'LIVE TRÌNH CHIẾU',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: () => _deleteRoom(context),
            tooltip: 'Xóa phòng',
          ),
        ],
      ),
      body: StreamBuilder<QuestRoom?>(
        stream: _questRoomService.watchRoom(widget.roomId),
        builder: (context, roomSnapshot) {
          final room = roomSnapshot.data;
          final topic = room?.topic ?? 'Đấu Trường Quiz';
          final pinCode = room?.pinCode ?? '------';
          final isFinished = room?.status == RoomStatus.finished;

          return SafeArea(
            child: Column(
              children: [
                // Room info header card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'PIN: $pinCode',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              topic,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Real-time Participants Stream
                Expanded(
                  child: StreamBuilder<List<Participant>>(
                    stream: _questRoomService.watchParticipants(widget.roomId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.secondary),
                        );
                      }

                      final participants = snapshot.data ?? [];
                      if (participants.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.people_outline_rounded,
                                size: 64,
                                color: Colors.white38,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Đang chờ người chơi tham gia...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Mã PIN: $pinCode',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Sort by score descending
                      final sorted = List<Participant>.from(participants)
                        ..sort((a, b) => b.score.compareTo(a.score));

                      final topThree = sorted.take(3).toList();
                      final rest = sorted.length > 3 ? sorted.sublist(3) : <Participant>[];

                      final completedCount =
                          sorted.where((p) => p.status == ParticipantStatus.finished).length;

                      return Column(
                        children: [
                          // Participant counter bar
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.people_rounded, size: 18, color: Colors.white70),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Người chơi: ${sorted.length}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF22C55E)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Đã xong: $completedCount/${sorted.length}',
                                      style: const TextStyle(
                                        color: Color(0xFF22C55E),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                children: [
                                  // Top 3 Podium Widget
                                  _LiveTopThreePodium(topThree: topThree),

                                  const SizedBox(height: 20),

                                  if (rest.isNotEmpty) ...[
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 10, left: 4),
                                        child: Text(
                                          'Bảng xếp hạng trực tiếp',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ...List.generate(rest.length, (index) {
                                      final p = rest[index];
                                      final rank = index + 4;

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E293B),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white10),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 32,
                                              child: Text(
                                                '#$rank',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white54,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
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
                                                      color: Colors.white,
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
                                                          : Colors.white38,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Animated Realtime Score Counter
                                            _AnimatedScoreText(score: p.score),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Host Controls Bottom Panel
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      if (!isFinished)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _endRoom(context, topic),
                            icon: const Icon(Icons.stop_circle_rounded, size: 20),
                            label: const Text('Dừng thi đấu'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      if (!isFinished) const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/home/quests'),
                          icon: const Icon(Icons.home_rounded, size: 20),
                          label: const Text('Về trang chủ'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LiveTopThreePodium extends StatelessWidget {
  final List<Participant> topThree;

  const _LiveTopThreePodium({required this.topThree});

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
              height: 95.0,
              color: const Color(0xFF94A3B8), // Silver
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
              height: 130.0,
              color: const Color(0xFFEAB308), // Gold
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
              height: 80.0,
              color: const Color(0xFFD97706), // Bronze
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
                  border: Border.all(color: color, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AppAvatar(
                  avatarUrl: participant.avatarId,
                  displayName: participant.displayName,
                  radius: hasCrown ? 30 : 24,
                ),
              ),
              if (hasCrown)
                const Positioned(
                  top: -22,
                  child: Text('👑', style: TextStyle(fontSize: 24)),
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
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          // Realtime Animated Score
          _AnimatedScoreText(score: participant.score, fontSize: 13),
          const SizedBox(height: 8),

          // Podium Pedestal Block
          Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(badge, style: const TextStyle(fontSize: 26)),
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

class _AnimatedScoreText extends StatelessWidget {
  final int score;
  final double fontSize;

  const _AnimatedScoreText({
    required this.score,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: score.toDouble()),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '${value.toInt()} điểm',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFF59E0B), // Warm Gold
          ),
        );
      },
    );
  }
}

