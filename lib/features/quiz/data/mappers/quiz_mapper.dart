import '../../../../core/mappers/mapper.dart';
import '../../../quiz_game/data/dtos/quiz_question_dto.dart';
import '../../../quiz_game/domain/entities/quiz_question.dart';
import '../../domain/entities/quiz_set.dart';
import '../dtos/quiz_set_dto.dart';

class QuizMapper implements IMapper<QuizSetDto, QuizSet> {
  @override
  QuizSet map(QuizSetDto source) {
    return QuizSet(
      id: source.id,
      title: source.title,
      description: source.description,
      imageUrl: source.imageUrl,
      creatorId: source.creatorId,
      isPublic: source.isPublic,
      createdAt: source.createdAt,
      questions: const [], // questions will be mapped separately via subcollection
    );
  }

  QuizSetDto toDto(QuizSet entity) {
    return QuizSetDto(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      imageUrl: entity.imageUrl,
      creatorId: entity.creatorId,
      isPublic: entity.isPublic,
      createdAt: entity.createdAt,
    );
  }

  QuizQuestion mapQuestionDtoToEntity(QuizQuestionDto dto) {
    return QuizQuestion(
      id: dto.id,
      text: dto.text,
      options: dto.options,
      correctIndex: dto.correctIndex,
      imageUrl: dto.imageUrl,
      timeLimit: dto.timeLimit,
      hintText: dto.hintText,
    );
  }

  QuizQuestionDto mapQuestionEntityToDto(QuizQuestion entity) {
    return QuizQuestionDto(
      id: entity.id,
      text: entity.text,
      options: entity.options,
      correctIndex: entity.correctIndex,
      imageUrl: entity.imageUrl,
      timeLimit: entity.timeLimit,
      hintText: entity.hintText,
    );
  }
}
