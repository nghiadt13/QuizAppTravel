import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/participant.dart';
import '../../domain/entities/quest_room.dart';
import '../../application/services/i_quest_room_service.dart';

class LobbyViewModel extends ChangeNotifier {
  final IQuestRoomService _service;

  LobbyViewModel(this._service);

  QuestRoom? _room;
  QuestRoom? get room => _room;

  List<Participant> _participants = [];
  List<Participant> get participants => _participants;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<QuestRoom?>? _roomSubscription;
  StreamSubscription<List<Participant>>? _participantsSubscription;

  void init(String roomId) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _roomSubscription?.cancel();
    _participantsSubscription?.cancel();

    _roomSubscription = _service.watchRoom(roomId).listen(
      (room) {
        _room = room;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );

    _participantsSubscription = _service.watchParticipants(roomId).listen(
      (participants) {
        _participants = participants;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> startQuest() async {
    if (_room == null) return;
    try {
      await _service.startQuest(_room!.id);
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to start quest.';
      notifyListeners();
    }
  }

  Future<void> leaveRoom(String playerId) async {
    if (_room == null) return;
    try {
      await _service.leaveRoom(_room!.id, playerId);
      _roomSubscription?.cancel();
      _participantsSubscription?.cancel();
      _room = null;
      _participants = [];
      notifyListeners();
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to leave quest room.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _participantsSubscription?.cancel();
    super.dispose();
  }
}
