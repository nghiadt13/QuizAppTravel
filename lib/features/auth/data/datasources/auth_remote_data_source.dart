import 'package:flutter/foundation.dart';
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
      User? firebaseUser;
      String? displayName;
      String? email;
      String? avatarUrl;

      if (kIsWeb) {
        // Web flow: Use browser popup to authenticate with Firebase Auth directly
        try {
          final GoogleAuthProvider googleProvider = GoogleAuthProvider();
          final UserCredential userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
          firebaseUser = userCredential.user;
          if (firebaseUser != null) {
            displayName = firebaseUser.displayName;
            email = firebaseUser.email;
            avatarUrl = firebaseUser.photoURL;
          }
        } catch (e) {
          if (e is AppException) rethrow;

          // Check if this is a cancellation error (popup closed or cancelled by user)
          bool isCancellation = false;
          if (e is FirebaseAuthException) {
            isCancellation = e.code == 'popup-closed-by-user' ||
                             e.code == 'web-context-cancelled' ||
                             e.code == 'auth/popup-closed-by-user' ||
                             e.code == 'cancelled-popup-request' ||
                             e.code == 'auth/cancelled-popup-request';
          }
          
          if (!isCancellation) {
            final errStr = e.toString().toLowerCase();
            isCancellation = errStr.contains('popup-closed-by-user') ||
                             errStr.contains('cancelled') ||
                             errStr.contains('closed-by-user') ||
                             errStr.contains('user-cancelled');
          }

          if (isCancellation) {
            throw const AppException('Sign in was cancelled.', code: 'cancelled');
          }
          
          rethrow;
        }
      } else {
        // Mobile flow: Use native Google Sign-In SDK
        // ignore: unnecessary_null_comparison, The native side can return null
        // on some Android devices when the user dismisses the dialog, even though
        // the Dart type signature is non-nullable.
        final googleUser = await _googleSignIn.authenticate();
        // ignore: unnecessary_null_comparison, dead_code
        if (googleUser == null) {
          throw const AppException('Sign in was cancelled.');
        }

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final String? idToken = googleAuth.idToken;
        if (idToken == null) {
          throw const AppException('Failed to retrieve ID Token from Google Sign-In.');
        }

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: idToken,
        );

        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        firebaseUser = userCredential.user;
        if (firebaseUser != null) {
          displayName = firebaseUser.displayName ?? googleUser.displayName;
          email = firebaseUser.email ?? googleUser.email;
          avatarUrl = firebaseUser.photoURL ?? googleUser.photoUrl;
        }
      }

      if (firebaseUser == null) {
        throw const AppException('Failed to retrieve user information from Google Sign-In.');
      }

      return HostUserDto(
        uid: firebaseUser.uid,
        displayName: displayName ?? 'Host',
        email: email ?? '',
        avatarUrl: avatarUrl,
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
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
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
