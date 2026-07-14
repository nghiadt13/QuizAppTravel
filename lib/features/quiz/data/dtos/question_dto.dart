class QuestionDto {
  final int id;
  final String content;
  final List<String> options;
  final int correctAnswerIndex;

  QuestionDto({
    required this.id,
    required this.content,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory QuestionDto.fromJson(Map<String, dynamic> json) {
    return QuestionDto(
      id: json['id'] as int,
      content: json['content'] as String,
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
    );
  }
}
