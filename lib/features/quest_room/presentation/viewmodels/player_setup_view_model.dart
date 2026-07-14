import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/preset_avatar.dart';
import '../../application/services/i_quest_room_service.dart';

class PlayerSetupViewModel extends ChangeNotifier {
  final IQuestRoomService _service;

  PlayerSetupViewModel(this._service);

  String? _displayName;
  String? get displayName => _displayName;

  String? _avatarId;
  String? get avatarId => _avatarId;

  String? _playerId;
  String? get playerId => _playerId;

  List<PresetAvatar> _avatars = [];
  List<PresetAvatar> get avatars => _avatars;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setDisplayName(String name) {
    _displayName = name.trim();
    notifyListeners();
  }

  void selectAvatar(String id) {
    _avatarId = id;
    notifyListeners();
  }

  Future<void> loadAvatars() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _avatars = await _service.getPresetAvatars();
      if (_avatars.isNotEmpty && _avatarId == null) {
        _avatarId = _avatars.first.id;
      }
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load avatars. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void generatePlayerId() {
    if (_playerId == null) {
      final random = Random();
      final part1 = random.nextInt(1000000).toString().padLeft(6, '0');
      final part2 = DateTime.now().millisecondsSinceEpoch.toString();
      _playerId = 'p-$part1-$part2';
    }
  }

  bool validate() {
    if (_displayName == null || _displayName!.trim().isEmpty) {
      _errorMessage = 'Display name cannot be empty.';
      notifyListeners();
      return false;
    }
    if (_avatarId == null) {
      _errorMessage = 'Please pick an avatar.';
      notifyListeners();
      return false;
    }
    _errorMessage = null;
    generatePlayerId();
    return true;
  }
}
