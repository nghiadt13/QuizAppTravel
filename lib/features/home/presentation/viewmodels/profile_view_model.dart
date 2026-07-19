import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../auth/application/services/i_auth_service.dart';
import '../../../auth/domain/entities/host_user.dart';
import '../../../quest_room/application/services/i_quest_room_service.dart';
import '../../../quest_room/domain/entities/quest_room.dart';

class ProfileViewModel extends ChangeNotifier {
  final IAuthService _authService;
  final IQuestRoomService _roomService;

  HostUser? _currentUser;
  HostUser? get currentUser => _currentUser;

  List<QuestRoom> _userRooms = [];
  List<QuestRoom> get userRooms => _userRooms;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileViewModel(this._authService, this._roomService) {
    // Listen to authentication state changes to keep profile updated
    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      if (user != null) {
        fetchUserRooms(user.uid);
      } else {
        _userRooms = [];
        notifyListeners();
      }
    });
  }

  Future<void> fetchUserRooms(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userRooms = await _roomService.getRoomsByHost(uid);
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load your rooms.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRoom(String roomId, String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _roomService.deleteRoom(roomId);
      _userRooms = await _roomService.getRoomsByHost(uid);
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to delete room.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
