import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/quest_room.dart';
import '../../application/services/i_quest_room_service.dart';

class JoinRoomViewModel extends ChangeNotifier {
  final IQuestRoomService _service;

  JoinRoomViewModel(this._service);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  QuestRoom? _joinedRoom;
  QuestRoom? get joinedRoom => _joinedRoom;

  Future<QuestRoom?> joinRoom({
    required String pinCode,
    required String displayName,
    required String avatarId,
    required String playerId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _joinedRoom = null;
    notifyListeners();

    try {
      _joinedRoom = await _service.joinRoom(
        pinCode: pinCode,
        displayName: displayName,
        avatarId: avatarId,
        playerId: playerId,
      );
      return _joinedRoom;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to join room. Please check the PIN code.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }
}
