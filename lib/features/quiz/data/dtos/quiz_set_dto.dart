import 'package:cloud_firestore/cloud_firestore.dart';

class QuizSetDto {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? creatorId;
  final bool isPublic;
  final DateTime createdAt;

  const QuizSetDto({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.creatorId,
    required this.isPublic,
    required this.createdAt,
  });

  factory QuizSetDto.fromFirestore(Map<String, dynamic> json, String id) {
    final timestamp = json['createdAt'] as Timestamp?;
    return QuizSetDto(
      id: id,
      title: json['topic'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      creatorId: json['creatorId'],
      isPublic: json['isPublic'] ?? true,
      createdAt: timestamp?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'topic': title,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'creatorId': creatorId,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
