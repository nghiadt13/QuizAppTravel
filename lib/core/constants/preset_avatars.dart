class PresetAvatars {
  static const list = [
    PresetAvatar(id: 'dog', label: 'Dog', assetPath: 'assets/avatars/dog.png'),
    PresetAvatar(id: 'cat', label: 'Cat', assetPath: 'assets/avatars/cat.png'),
    PresetAvatar(id: 'bird', label: 'Bird', assetPath: 'assets/avatars/bird.png'),
    PresetAvatar(id: 'rabbit', label: 'Rabbit', assetPath: 'assets/avatars/rabbit.png'),
    PresetAvatar(id: 'fox', label: 'Fox', assetPath: 'assets/avatars/fox.png'),
    PresetAvatar(id: 'owl', label: 'Owl', assetPath: 'assets/avatars/owl.png'),
  ];
}

class PresetAvatar {
  final String id;
  final String label;
  final String assetPath;
  
  const PresetAvatar({
    required this.id,
    required this.label,
    required this.assetPath,
  });
}
