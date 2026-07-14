import '../../domain/entities/host_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'i_auth_service.dart';

class AuthServiceImpl implements IAuthService {
  final IAuthRepository _repository;

  AuthServiceImpl(this._repository);

  @override
  Stream<HostUser?> get authStateChanges => _repository.authStateChanges;

  @override
  Future<HostUser> signInWithGoogle() async {
    return _repository.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    await _repository.signOut();
  }

  @override
  Future<HostUser?> getCurrentUser() async {
    return _repository.getCurrentUser();
  }
}
