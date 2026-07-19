import '../../../quiz_game/domain/entities/quiz_question.dart';

class QuizSet {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? creatorId;
  final bool isPublic;
  final DateTime createdAt;
  final List<QuizQuestion> questions;

  const QuizSet({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.creatorId,
    this.isPublic = true,
    required this.createdAt,
    required this.questions,
  });

  QuizSet copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? creatorId,
    bool? isPublic,
    DateTime? createdAt,
    List<QuizQuestion>? questions,
  }) {
    return QuizSet(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      creatorId: creatorId ?? this.creatorId,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      questions: questions ?? this.questions,
    );
  }
}
