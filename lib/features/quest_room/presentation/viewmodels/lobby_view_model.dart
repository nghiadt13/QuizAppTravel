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

  Future<void> init(String roomId, {QuestRoom? initialRoom}) async {
    _errorMessage = null;
    _participants = [];

    if (initialRoom != null && initialRoom.id == roomId) {
      _room = initialRoom;
      _isLoading = false;
      notifyListeners();
    } else {
      _isLoading = true;
      _room = null;
      notifyListeners();
    }

    _roomSubscription?.cancel();
    _participantsSubscription?.cancel();

    // 1. Direct fetch immediately with a strict timeout so UI never hangs
    try {
      final directRoom = await _service.getRoomById(roomId).timeout(
        const Duration(milliseconds: 2500),
      );
      if (directRoom != null) {
        _room = directRoom;
        _isLoading = false;
        notifyListeners();
      }
    } catch (_) {}

    try {
      final directParticipants = await _service.getParticipants(roomId).timeout(
        const Duration(milliseconds: 2500),
      );
      if (directParticipants.isNotEmpty) {
        _participants = directParticipants;
        notifyListeners();
      }
    } catch (_) {}

    // Safety timeout to turn off loading after 2.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    });

    _roomSubscription = _service.watchRoom(roomId).listen(
      (room) {
        if (room != null) {
          _room = room;
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        if (_room == null) {
          _errorMessage = error.toString();
        }
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
