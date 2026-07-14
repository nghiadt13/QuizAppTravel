import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/quest_room.dart';
import '../../application/services/i_quest_room_service.dart';

class BrowseQuestsViewModel extends ChangeNotifier {
  final IQuestRoomService _service;

  BrowseQuestsViewModel(this._service);

  List<QuestRoom> _rooms = [];
  List<QuestRoom> get rooms => _rooms;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPublicRooms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rooms = await _service.getActivePublicRooms();
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to fetch public quests.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
