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
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _service.signInWithGoogle();
    } on AppException catch (e) {
      // If user cancelled, don't show error — just reset the button
      if (e.message != 'Sign in was cancelled.' && e.code != 'cancelled') {
        _errorMessage = e.message;
      }
    } catch (e) {
      _errorMessage = 'An error occurred during Google Sign-In.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetLoadingState() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (_isLoading) return;

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
