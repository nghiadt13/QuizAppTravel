import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/quest_room.dart';
import '../../application/services/i_quest_room_service.dart';

class CreateRoomViewModel extends ChangeNotifier {
  final IQuestRoomService _service;

  CreateRoomViewModel(this._service);

  String _topic = '';
  String get topic => _topic;

  bool _isPublic = true;
  bool get isPublic => _isPublic;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  QuestRoom? _createdRoom;
  QuestRoom? get createdRoom => _createdRoom;

  final List<String> _presetTopics = [
    'Southeast Asia Adventure',
    'European History & Landmarks',
    'Wonders of the World',
    'Culinary Journeys',
    'Tropical Islands & Beaches',
  ];
  List<String> get presetTopics => _presetTopics;

  void setTopic(String topic) {
    _topic = topic;
    notifyListeners();
  }

  void toggleIsPublic(bool value) {
    _isPublic = value;
    notifyListeners();
  }

  Future<QuestRoom?> createRoom(String hostId) async {
    if (_topic.trim().isEmpty) {
      _errorMessage = 'Please enter or select a topic.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    _createdRoom = null;
    notifyListeners();

    try {
      _createdRoom = await _service.createRoom(
        topic: _topic,
        hostId: hostId,
        isPublic: _isPublic,
      );
      return _createdRoom;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to create room. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }
}
