import '../entities/host_user.dart';

abstract interface class IAuthRepository {
  Future<HostUser> signInWithGoogle();
  Future<void> signOut();
  Future<HostUser?> getCurrentUser();
  Stream<HostUser?> get authStateChanges;
}
