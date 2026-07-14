import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntryDto {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int totalScore;
  final int gamesPlayed;
  final DateTime lastPlayed;

  const LeaderboardEntryDto({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.totalScore,
    required this.gamesPlayed,
    required this.lastPlayed,
  });

  factory LeaderboardEntryDto.fromFirestore(Map<String, dynamic> json, String id) {
    return LeaderboardEntryDto(
      userId: id,
      displayName: json['displayName'] ?? '',
      avatarUrl: json['avatarUrl'],
      totalScore: json['totalScore'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
      lastPlayed: json['lastPlayed'] != null
          ? (json['lastPlayed'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'totalScore': totalScore,
      'gamesPlayed': gamesPlayed,
      'lastPlayed': FieldValue.serverTimestamp(),
    };
  }
}
