import 'package:get_it/get_it.dart';
import 'package:quiz_app_travel/features/quiz/application/services/i_quiz_service.dart';
import 'package:quiz_app_travel/features/quiz/application/services/quiz_service.dart';
import 'package:quiz_app_travel/features/quiz/data/datasource/quiz_remote_data_source.dart';
import 'package:quiz_app_travel/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:quiz_app_travel/features/quiz/domain/repositories/i_quiz_repository.dart';
import 'package:quiz_app_travel/features/quiz/presentation/viewmodels/quiz_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Data sources
  getIt.registerLazySingleton<QuizRemoteDataSource>(() => QuizRemoteDataSource());

  // Repositories
  getIt.registerLazySingleton<IQuizRepository>(
    () => QuizRepositoryImpl(getIt<QuizRemoteDataSource>()),
  );

  // Services
  getIt.registerLazySingleton<IQuizService>(
    () => QuizService(getIt<IQuizRepository>()),
  );

  // ViewModels (Use Factory so it creates a new instance, or LazySingleton if you want a global state)
  // For a game, global state or scoped state is fine. Let's use LazySingleton for easy access.
  getIt.registerLazySingleton<QuizViewModel>(
    () => QuizViewModel(getIt<IQuizService>()),
  );
}
