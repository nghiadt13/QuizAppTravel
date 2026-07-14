import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../application/services/i_leaderboard_service.dart';

class LeaderboardViewModel extends ChangeNotifier {
  final ILeaderboardService _service;

  LeaderboardViewModel(this._service);

  List<LeaderboardEntry> _entries = [];
  List<LeaderboardEntry> get entries => _entries;

  LeaderboardEntry? _userRank;
  LeaderboardEntry? get userRank => _userRank;

  String _period = '2026-07'; // current active month period
  String get period => _period;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = false;
  bool get hasMore => _hasMore;

  DateTime? _seasonEndDate;
  DateTime? get seasonEndDate => _seasonEndDate;

  String? _rewardDescription;
  String? get rewardDescription => _rewardDescription;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<LeaderboardEntry?>? _userRankSubscription;

  Future<void> loadLeaderboard({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    if (refresh) {
      _entries = [];
      notifyListeners();
    }

    try {
      final lastUserId = refresh ? null : (_entries.isNotEmpty ? _entries.last.userId : null);
      final leaderboard = await _service.getLeaderboard(
        _period,
        limit: 20,
        lastUserId: lastUserId,
      );

      if (refresh) {
        _entries = leaderboard.entries;
      } else {
        _entries.addAll(leaderboard.entries);
      }

      _hasMore = leaderboard.hasMore;
      _seasonEndDate = leaderboard.seasonEndDate;
      _rewardDescription = leaderboard.rewardDescription;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load leaderboard data.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void initUserRanking(String userId) {
    if (userId.isEmpty) return;
    _userRankSubscription?.cancel();
    _userRankSubscription = _service.watchUserRank(_period, userId).listen(
      (rankInfo) {
        _userRank = rankInfo;
        notifyListeners();
      },
      onError: (err) {
        // Handle error silently or set message
      },
    );
  }

  void changePeriod(String newPeriod, String userId) {
    if (_period == newPeriod) return;
    _period = newPeriod;
    initUserRanking(userId);
    loadLeaderboard(refresh: true);
  }

  @override
  void dispose() {
    _userRankSubscription?.cancel();
    super.dispose();
  }
}
