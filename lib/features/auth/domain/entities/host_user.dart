class HostUser {
  final String uid;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;

  const HostUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
  });
}
