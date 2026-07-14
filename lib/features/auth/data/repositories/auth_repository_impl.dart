import '../../domain/entities/host_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../mappers/host_user_mapper.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;
  final HostUserMapper _mapper;

  AuthRepositoryImpl(this._remoteDataSource, this._mapper);

  @override
  Stream<HostUser?> get authStateChanges {
    return _remoteDataSource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      final dto = await _remoteDataSource.getHostProfile(firebaseUser.uid);
      if (dto != null) {
        return _mapper.map(dto);
      }
      return HostUser(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? 'Host',
        email: firebaseUser.email ?? '',
        avatarUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
      );
    });
  }

  @override
  Future<HostUser> signInWithGoogle() async {
    final dto = await _remoteDataSource.signInWithGoogle();
    
    // Check if host profile exists in Firestore, if not create one
    final existingProfile = await _remoteDataSource.getHostProfile(dto.uid);
    if (existingProfile == null) {
      await _remoteDataSource.saveHostProfile(dto);
      return _mapper.map(dto);
    }
    
    return _mapper.map(existingProfile);
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<HostUser?> getCurrentUser() async {
    final firebaseUser = await _remoteDataSource.authStateChanges.first.timeout(
      const Duration(milliseconds: 500),
      onTimeout: () => null,
    );
    if (firebaseUser == null) return null;
    
    final dto = await _remoteDataSource.getHostProfile(firebaseUser.uid);
    if (dto == null) return null;
    
    return _mapper.map(dto);
  }
}
