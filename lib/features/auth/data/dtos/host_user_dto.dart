import 'package:cloud_firestore/cloud_firestore.dart';

class HostUserDto {
  final String uid;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;

  const HostUserDto({
    required this.uid,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
  });

  factory HostUserDto.fromFirestore(Map<String, dynamic> json, String id) {
    return HostUserDto(
      uid: id,
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
