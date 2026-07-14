import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantDto {
  final String playerId;
  final String displayName;
  final String avatarId;
  final String status;
  final int score;
  final int currentQuestionIndex;
  final DateTime joinedAt;

  const ParticipantDto({
    required this.playerId,
    required this.displayName,
    required this.avatarId,
    required this.status,
    required this.score,
    required this.currentQuestionIndex,
    required this.joinedAt,
  });

  factory ParticipantDto.fromFirestore(Map<String, dynamic> json, String id) {
    return ParticipantDto(
      playerId: id,
      displayName: json['displayName'] ?? '',
      avatarId: json['avatarId'] ?? '',
      status: json['status'] ?? 'joined',
      score: json['score'] ?? 0,
      currentQuestionIndex: json['currentQuestionIndex'] ?? 0,
      joinedAt: json['joinedAt'] != null
          ? (json['joinedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'avatarId': avatarId,
      'status': status,
      'score': score,
      'currentQuestionIndex': currentQuestionIndex,
      'joinedAt': FieldValue.serverTimestamp(),
    };
  }
}
