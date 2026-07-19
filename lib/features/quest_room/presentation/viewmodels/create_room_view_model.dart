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

  String? _selectedQuizId;
  String? get selectedQuizId => _selectedQuizId;

  final List<String> _presetTopics = [
    'General Knowledge',
    'Science & Technology',
    'History & Culture',
    'Sports & Entertainment',
    'Geography & Nature',
  ];
  List<String> get presetTopics => _presetTopics;

  void setTopic(String topic) {
    _topic = topic;
    notifyListeners();
  }

  void selectQuiz(String? quizId, String quizTitle) {
    _selectedQuizId = quizId;
    _topic = quizTitle;
    notifyListeners();
  }

  void resetSelection() {
    _selectedQuizId = null;
    _topic = '';
    notifyListeners();
  }

  void toggleIsPublic(bool value) {
    _isPublic = value;
    notifyListeners();
  }

  Future<QuestRoom?> createRoom(String hostId) async {
    if (_topic.trim().isEmpty) {
      _errorMessage = 'Vui lòng nhập hoặc chọn chủ đề.';
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
        quizId: _selectedQuizId,
      );
      return _createdRoom;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Không thể tạo phòng game. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }
}
