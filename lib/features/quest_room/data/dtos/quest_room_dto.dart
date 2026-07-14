import 'package:cloud_firestore/cloud_firestore.dart';

class QuestRoomDto {
  final String id;
  final String pinCode;
  final String topic;
  final String hostId;
  final String status;
  final bool isPublic;
  final DateTime createdAt;

  const QuestRoomDto({
    required this.id,
    required this.pinCode,
    required this.topic,
    required this.hostId,
    required this.status,
    required this.isPublic,
    required this.createdAt,
  });

  factory QuestRoomDto.fromFirestore(Map<String, dynamic> json, String id) {
    return QuestRoomDto(
      id: id,
      pinCode: json['pinCode'] ?? '',
      topic: json['topic'] ?? '',
      hostId: json['hostId'] ?? '',
      status: json['status'] ?? 'waiting',
      isPublic: json['isPublic'] ?? false,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'pinCode': pinCode,
      'topic': topic,
      'hostId': hostId,
      'status': status,
      'isPublic': isPublic,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
