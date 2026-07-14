import 'leaderboard_entry.dart';

class Leaderboard {
  final String period; // "2026-07" or "all-time"
  final List<LeaderboardEntry> entries;
  final DateTime? seasonEndDate;
  final String? rewardDescription;
  final bool hasMore;

  const Leaderboard({
    required this.period,
    required this.entries,
    this.seasonEndDate,
    this.rewardDescription,
    required this.hasMore,
  });
}
