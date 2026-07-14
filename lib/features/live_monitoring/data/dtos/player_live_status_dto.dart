import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerLiveStatusDto {
  final String userId;
  final String displayName;
  final String? avatarId;
  final int currentQuestionIndex;
  final int score;
  final String status;
  final DateTime? finishedAt;
  final int? rank;

  const PlayerLiveStatusDto({
    required this.userId,
    required this.displayName,
    this.avatarId,
    required this.currentQuestionIndex,
    required this.score,
    required this.status,
    this.finishedAt,
    this.rank,
  });

  factory PlayerLiveStatusDto.fromFirestore(Map<String, dynamic> json, String id) {
    return PlayerLiveStatusDto(
      userId: id,
      displayName: json['displayName'] ?? '',
      avatarId: json['avatarId'],
      currentQuestionIndex: json['currentQuestionIndex'] ?? 0,
      score: json['score'] ?? 0,
      status: json['status'] ?? 'playing',
      finishedAt: json['finishedAt'] != null
          ? (json['finishedAt'] as Timestamp).toDate()
          : null,
      rank: json['rank'],
    );
  }
}
