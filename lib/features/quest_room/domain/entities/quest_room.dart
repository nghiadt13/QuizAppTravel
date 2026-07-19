enum RoomStatus {
  waiting,
  playing,
  finished,
}

class QuestRoom {
  final String id;
  final String pinCode;
  final String topic;
  final String hostId;
  final RoomStatus status;
  final bool isPublic;
  final DateTime createdAt;
  final String? quizId;

  const QuestRoom({
    required this.id,
    required this.pinCode,
    required this.topic,
    required this.hostId,
    required this.status,
    required this.isPublic,
    required this.createdAt,
    this.quizId,
  });
}
