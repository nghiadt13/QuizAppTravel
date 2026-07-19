import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'core/di/di.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/viewmodels/auth_view_model.dart';
import 'features/quest_room/presentation/viewmodels/player_setup_view_model.dart';
import 'features/quest_room/presentation/viewmodels/create_room_view_model.dart';
import 'features/quest_room/presentation/viewmodels/join_room_view_model.dart';
import 'features/quest_room/presentation/viewmodels/browse_quests_view_model.dart';
import 'features/quest_room/presentation/viewmodels/lobby_view_model.dart';
import 'features/quiz_game/presentation/viewmodels/quiz_play_view_model.dart';
import 'features/live_monitoring/presentation/viewmodels/host_control_view_model.dart';
import 'features/reward/presentation/viewmodels/open_chest_view_model.dart';
import 'features/leaderboard/presentation/viewmodels/leaderboard_view_model.dart';
import 'features/home/presentation/viewmodels/profile_view_model.dart';
import 'features/quiz/presentation/viewmodels/quiz_manager_view_model.dart';
import 'core/database/database_seeder.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  String? initError;

  try {
    // Initialize Firebase with generated options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Seed mock quizzes if database is empty
    await DatabaseSeeder.seedQuizzesIfEmpty();
  } catch (e) {
    initError = 'Firebase Initialization Error: $e';
    debugPrint(initError);
  }
  
  try {
    // Set up dependency injection (GetIt)
    await setupDependencies();
  } catch (e) {
    initError = '${initError ?? ''}\nDependency Injection Error: $e';
    debugPrint('DI Setup Error: $e');
  }

  if (!kIsWeb) {
    try {
      await GoogleSignIn.instance.initialize();
    } catch (e) {
      debugPrint('Google Sign-In initialization failed: $e');
    }
  } else {
    debugPrint('Google Sign-In initialization bypassed on Web (no Client ID configured).');
  }

  runApp(MyApp(initializationError: initError));
}


class MyApp extends StatelessWidget {
  final String? initializationError;

  const MyApp({super.key, this.initializationError});

  @override
  Widget build(BuildContext context) {
    if (initializationError != null) {
      return MaterialApp(
        title: 'Quiz App - Error',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          backgroundColor: const Color(0xFFF7F9FB),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 80,
                    color: Color(0xFFBA1A1A),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'App Initialization Failed',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00475E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBA1A1A).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      initializationError!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Vui lòng xác minh cấu hình Firebase của bạn trong file firebase_options.dart và xây dựng lại.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final appRouter = getIt<AppRouter>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<PlayerSetupViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<CreateRoomViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<JoinRoomViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<BrowseQuestsViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<LobbyViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<QuizPlayViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<HostControlViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<OpenChestViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<LeaderboardViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<ProfileViewModel>()),
        ChangeNotifierProvider(create: (_) => getIt<QuizManagerViewModel>()),
      ],
      child: MaterialApp.router(
        title: 'Quiz App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter.router,
      ),
    );
  }
}



class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.quiz_outlined,
                size: 100,
                color: Colors.teal,
              ),
              const SizedBox(height: 24),
              Text(
                'Chào mừng đến với Quiz App!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Dự án này được thiết lập theo cấu trúc Clean/MVVM Feature-First mô-đun hóa và tích hợp Firebase.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kết nối Firebase & DI thành công!'),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Kiểm tra trạng thái'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
