class QuizQuestionDto {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String? imageUrl;
  final int timeLimit;
  final String? hintText;

  const QuizQuestionDto({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.imageUrl,
    required this.timeLimit,
    this.hintText,
  });

  factory QuizQuestionDto.fromFirestore(Map<String, dynamic> json, String id) {
    return QuizQuestionDto(
      id: id,
      text: json['text'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
      imageUrl: json['imageUrl'],
      timeLimit: json['timeLimit'] ?? 30,
      hintText: json['hintText'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'options': options,
      'correctIndex': correctIndex,
      'imageUrl': imageUrl,
      'timeLimit': timeLimit,
      'hintText': hintText,
    };
  }
}
