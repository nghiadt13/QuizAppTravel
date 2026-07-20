import 'package:cloud_firestore/cloud_firestore.dart';

class QuestRoomDto {
  final String id;
  final String pinCode;
  final String topic;
  final String hostId;
  final String status;
  final bool isPublic;
  final DateTime createdAt;

  final String? quizId;

  const QuestRoomDto({
    required this.id,
    required this.pinCode,
    required this.topic,
    required this.hostId,
    required this.status,
    required this.isPublic,
    required this.createdAt,
    this.quizId,
  });

  factory QuestRoomDto.fromFirestore(Map<String, dynamic> json, String id) {
    DateTime parsedDate = DateTime.now();
    final rawDate = json['createdAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    }

    return QuestRoomDto(
      id: id,
      pinCode: json['pinCode']?.toString() ?? '',
      topic: json['topic']?.toString() ?? '',
      hostId: json['hostId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'waiting',
      isPublic: json['isPublic'] == true,
      createdAt: parsedDate,
      quizId: json['quizId']?.toString(),
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
      'quizId': quizId,
    };
  }
}
