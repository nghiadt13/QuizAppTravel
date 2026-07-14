class PresetAvatarDto {
  final String id;
  final String label;
  final String imageUrl;
  final int order;

  const PresetAvatarDto({
    required this.id,
    required this.label,
    required this.imageUrl,
    required this.order,
  });

  factory PresetAvatarDto.fromFirestore(Map<String, dynamic> json, String id) {
    return PresetAvatarDto(
      id: id,
      label: json['label'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      order: json['order'] ?? 0,
    );
  }
}
