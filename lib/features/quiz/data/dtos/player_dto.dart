class PlayerDto {
  final String name;
  final int score;

  PlayerDto({
    required this.name,
    required this.score,
  });

  factory PlayerDto.fromJson(Map<String, dynamic> json) {
    return PlayerDto(
      name: json['name'] as String,
      score: json['score'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'score': score,
    };
  }
}
