import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/app_exception.dart';
import '../dtos/host_user_dto.dart';

abstract interface class IAuthRemoteDataSource {
  Future<HostUserDto> signInWithGoogle();
  Future<void> signOut();
  Future<HostUserDto?> getHostProfile(String uid);
  Future<void> saveHostProfile(HostUserDto user);
  Stream<User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl(
    this._firebaseAuth,
    this._googleSignIn,
    this._firestore,
  );

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<HostUserDto> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        throw const AppException('Failed to retrieve ID Token from Google Sign-In.');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const AppException('Failed to retrieve user information from Google Sign-In.');
      }

      return HostUserDto(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? googleUser.displayName ?? 'Host',
        email: firebaseUser.email ?? googleUser.email,
        avatarUrl: firebaseUser.photoURL ?? googleUser.photoUrl,
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw AppException(e.message ?? 'Authentication error occurred.', code: e.code);
    } on Exception catch (e) {
      if (e is AppException) rethrow;
      throw AppException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AppException(e.message ?? 'Sign out failed.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<HostUserDto?> getHostProfile(String uid) async {
    try {
      final doc = await _firestore.collection('hosts').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return HostUserDto.fromFirestore(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to load host profile.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  @override
  Future<void> saveHostProfile(HostUserDto user) async {
    try {
      await _firestore.collection('hosts').doc(user.uid).set(user.toFirestore());
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to save host profile.', code: e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }
}
