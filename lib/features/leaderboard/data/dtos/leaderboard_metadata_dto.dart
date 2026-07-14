import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardMetadataDto {
  final DateTime? seasonEndDate;
  final String? rewardDescription;

  const LeaderboardMetadataDto({
    this.seasonEndDate,
    this.rewardDescription,
  });

  factory LeaderboardMetadataDto.fromFirestore(Map<String, dynamic> json) {
    return LeaderboardMetadataDto(
      seasonEndDate: json['seasonEndDate'] != null
          ? (json['seasonEndDate'] as Timestamp).toDate()
          : null,
      rewardDescription: json['rewardDescription'] as String?,
    );
  }
}
