class TravelRewardDto {
  final String id;
  final String type;
  final String title;
  final String description;
  final int value;
  final String? iconUrl;

  const TravelRewardDto({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.value,
    this.iconUrl,
  });

  factory TravelRewardDto.fromFirestore(Map<String, dynamic> json, String id) {
    return TravelRewardDto(
      id: id,
      type: json['type'] ?? 'travelCoins',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      value: json['value'] ?? 0,
      iconUrl: json['iconUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'value': value,
      'iconUrl': iconUrl,
    };
  }
}
