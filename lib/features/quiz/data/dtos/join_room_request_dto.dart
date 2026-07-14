class JoinRoomRequestDto {
  final String pin;
  final String playerName;

  JoinRoomRequestDto({
    required this.pin,
    required this.playerName,
  });

  Map<String, dynamic> toJson() {
    return {
      'pin': pin,
      'playerName': playerName,
    };
  }
}
