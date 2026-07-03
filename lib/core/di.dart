import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // ==========================================
  // 1. External / Firebase Services
  // ==========================================
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // ==========================================
  // 2. Feature: Auth
  // ==========================================
  // Data Sources
  // getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(getIt()));
  
  // Repositories
  // getIt.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(getIt()));

  // ViewModels
  // getIt.registerFactory(() => AuthViewModel(getIt()));

  // ==========================================
  // 3. Feature: Quiz
  // ==========================================
  // Data Sources
  // getIt.registerLazySingleton<QuizRemoteDataSource>(() => QuizRemoteDataSource(getIt()));
  
  // Repositories
  // getIt.registerLazySingleton<IQuizRepository>(() => QuizRepositoryImpl(getIt()));

  // ViewModels
  // getIt.registerFactory(() => QuizViewModel(getIt()));

  // ==========================================
  // 4. Feature: Travel
  // ==========================================
  // Data Sources
  // getIt.registerLazySingleton<TravelRemoteDataSource>(() => TravelRemoteDataSource(getIt()));
  
  // Repositories
  // getIt.registerLazySingleton<ITravelRepository>(() => TravelRepositoryImpl(getIt()));

  // ViewModels
  // getIt.registerFactory(() => TravelViewModel(getIt()));
}
