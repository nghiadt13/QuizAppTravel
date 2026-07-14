import '../../domain/entities/host_user.dart';

abstract interface class IAuthService {
  Future<HostUser> signInWithGoogle();
  Future<void> signOut();
  Future<HostUser?> getCurrentUser();
  Stream<HostUser?> get authStateChanges;
}
