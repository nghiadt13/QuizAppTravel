import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/travel_reward.dart';
import '../../application/services/i_reward_service.dart';

class OpenChestViewModel extends ChangeNotifier {
  final IRewardService _service;

  OpenChestViewModel(this._service);

  int _tapCount = 0;
  int get tapCount => _tapCount;

  bool _isShaking = false;
  bool get isShaking => _isShaking;

  bool _isOpened = false;
  bool get isOpened => _isOpened;

  TravelReward? _reward;
  TravelReward? get reward => _reward;

  bool _isClaimed = false;
  bool get isClaimed => _isClaimed;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Timer? _shakeTimer;

  Future<void> tapChest(String userId) async {
    if (_isOpened || _isLoading) return;

    _tapCount++;
    if (_tapCount < 3) {
      _isShaking = true;
      notifyListeners();

      _shakeTimer?.cancel();
      _shakeTimer = Timer(const Duration(milliseconds: 150), () {
        _isShaking = false;
        notifyListeners();
      });
    } else {
      // Tap count is 3: Open Chest!
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      try {
        _reward = await _service.getRandomReward();
        _isOpened = true;
      } on AppException catch (e) {
        _errorMessage = e.message;
        _tapCount = 2; // Allow retry on tap
      } catch (e) {
        _errorMessage = 'Failed to open chest. Try tapping again!';
        _tapCount = 2;
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> claimReward(String userId) async {
    if (_reward == null || _isClaimed || _isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.claimReward(userId, _reward!);
      _isClaimed = true;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to claim reward. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _tapCount = 0;
    _isShaking = false;
    _isOpened = false;
    _reward = null;
    _isClaimed = false;
    _isLoading = false;
    _errorMessage = null;
    _shakeTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _shakeTimer?.cancel();
    super.dispose();
  }
}
