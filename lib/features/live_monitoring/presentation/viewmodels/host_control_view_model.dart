import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/player_live_status.dart';
import '../../application/services/i_monitoring_service.dart';

class HostControlViewModel extends ChangeNotifier {
  final IMonitoringService _service;

  HostControlViewModel(this._service);

  String _roomId = '';

  List<PlayerLiveStatus> _players = [];
  List<PlayerLiveStatus> get players => _players;

  String _roomStatus = 'playing';
  String get roomStatus => _roomStatus;

  int get completedCount => _players.where((p) => p.status == PlayerGameStatus.finished).length;
  int get activeCount => _players.where((p) => p.status == PlayerGameStatus.playing).length;

  int _timeRemaining = 300; // 5 minutes default countdown
  int get timeRemaining => _timeRemaining;

  StreamSubscription<List<PlayerLiveStatus>>? _playersSubscription;
  StreamSubscription<String>? _roomStatusSubscription;
  Timer? _countdownTimer;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void init(String roomId, int totalQuestions) {
    _roomId = roomId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _playersSubscription?.cancel();
    _roomStatusSubscription?.cancel();
    _countdownTimer?.cancel();

    _playersSubscription = _service.watchPlayerStatuses(roomId, totalQuestions).listen(
      (players) {
        _players = players;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );

    _roomStatusSubscription = _service.watchRoomStatus(roomId).listen(
      (status) {
        _roomStatus = status;
        if (status == 'playing') {
          _startCountdown();
        } else {
          _countdownTimer?.cancel();
        }
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        notifyListeners();
      },
    );
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        _countdownTimer?.cancel();
        endGame();
      }
    });
  }

  Future<void> pauseGame() async {
    try {
      await _service.pauseGame(_roomId);
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> resumeGame() async {
    try {
      await _service.resumeGame(_roomId);
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> endGame() async {
    try {
      await _service.endGame(_roomId);
      _countdownTimer?.cancel();
      _timeRemaining = 0;
      notifyListeners();
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _playersSubscription?.cancel();
    _roomStatusSubscription?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
