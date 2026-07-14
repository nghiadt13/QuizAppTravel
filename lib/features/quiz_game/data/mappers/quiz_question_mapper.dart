import '../../../../core/mappers/mapper.dart';
import '../../domain/entities/quiz_question.dart';
import '../dtos/quiz_question_dto.dart';

class QuizQuestionMapper implements IMapper<QuizQuestionDto, QuizQuestion> {
  @override
  QuizQuestion map(QuizQuestionDto source) {
    return QuizQuestion(
      id: source.id,
      text: source.text,
      options: source.options,
      correctIndex: source.correctIndex,
      imageUrl: source.imageUrl,
      timeLimit: source.timeLimit,
      hintText: source.hintText,
    );
  }
}
