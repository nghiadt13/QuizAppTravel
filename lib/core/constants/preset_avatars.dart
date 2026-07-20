class PresetAvatars {
  static const list = [
    PresetAvatar(
      id: 'dog',
      label: 'Cún con',
      assetPath: 'assets/avatars/dog.png',
    ),
    PresetAvatar(
      id: 'cat',
      label: 'Mèo nhỏ',
      assetPath: 'assets/avatars/cat.png',
    ),
    PresetAvatar(
      id: 'bird',
      label: 'Chim xanh',
      assetPath: 'assets/avatars/bird.png',
    ),
    PresetAvatar(
      id: 'rabbit',
      label: 'Thỏ bông',
      assetPath: 'assets/avatars/rabbit.png',
    ),
    PresetAvatar(
      id: 'fox',
      label: 'Cáo cam',
      assetPath: 'assets/avatars/fox.png',
    ),
    PresetAvatar(
      id: 'owl',
      label: 'Cú mèo',
      assetPath: 'assets/avatars/owl.png',
    ),
    PresetAvatar(
      id: 'panda',
      label: 'Gấu trúc',
      assetPath: 'assets/avatars/panda.png',
    ),
    PresetAvatar(
      id: 'bear',
      label: 'Gấu nâu',
      assetPath: 'assets/avatars/bear.png',
    ),
    PresetAvatar(
      id: 'koala',
      label: 'Koala',
      assetPath: 'assets/avatars/koala.png',
    ),
    PresetAvatar(
      id: 'penguin',
      label: 'Cánh cụt',
      assetPath: 'assets/avatars/penguin.png',
    ),
    PresetAvatar(
      id: 'monkey',
      label: 'Khỉ con',
      assetPath: 'assets/avatars/monkey.png',
    ),
    PresetAvatar(
      id: 'tiger',
      label: 'Hổ con',
      assetPath: 'assets/avatars/tiger.png',
    ),
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
