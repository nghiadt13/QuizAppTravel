import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/errors/app_exception.dart';
import '../../application/services/i_auth_service.dart';
import '../../domain/entities/host_user.dart';

class AuthViewModel extends ChangeNotifier {
  final IAuthService _service;
  StreamSubscription<HostUser?>? _authSubscription;

  HostUser? _currentUser;
  HostUser? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null;

  AuthViewModel(this._service) {
    _authSubscription = _service.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('[AuthVM] Starting sign in...');
      _currentUser = await _service.signInWithGoogle();
      print('[AuthVM] Sign in successful: ${_currentUser?.email}');
    } on AppException catch (e) {
      print('[AuthVM] AppException: ${e.message}');
      _errorMessage = e.message;
    } catch (e) {
      print('[AuthVM] Error: $e');
      _errorMessage = 'An error occurred during Google Sign-In.';
    } finally {
      _isLoading = false;
      print('[AuthVM] Notifying listeners...');
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.signOut();
      _currentUser = null;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to sign out.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
