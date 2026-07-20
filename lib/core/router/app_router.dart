import 'package:go_router/go_router.dart';
import '../di/di.dart';
import '../../features/auth/presentation/viewmodels/auth_view_model.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/home/presentation/views/home_shell_screen.dart';
import '../../features/home/presentation/views/leaderboard_tab_screen.dart';
import '../../features/home/presentation/views/profile_tab_screen.dart';
import '../../features/home/presentation/views/quests_tab_screen.dart';
import '../../features/home/presentation/views/shop_tab_screen.dart';
import '../../features/home/presentation/views/history_tab_screen.dart';
import '../../features/live_monitoring/presentation/views/live_monitoring_screen.dart';
import '../../features/quest_room/presentation/views/player_setup_screen.dart';
import '../../features/quest_room/presentation/views/create_room_screen.dart';
import '../../features/quest_room/presentation/views/join_room_screen.dart';
import '../../features/quest_room/presentation/views/browse_quests_screen.dart';
import '../../features/quest_room/presentation/views/lobby_screen.dart';
import '../../features/quiz_game/presentation/views/quiz_play_screen.dart';
import '../../features/quiz/presentation/views/create_quiz_screen.dart';
import '../../features/quiz/presentation/views/quiz_detail_screen.dart';
import '../../features/quiz/presentation/views/all_topics_screen.dart';
import '../../features/quiz/domain/entities/quiz_set.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: getIt<AuthViewModel>(),
    redirect: (context, state) {
      final authViewModel = getIt<AuthViewModel>();
      final isLoggedIn = authViewModel.isAuthenticated;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        final path = state.uri.toString();
        if (path.startsWith('/home') || path == '/') {
          return '/login';
        }
      }

      if (isLoggedIn && isLoggingIn) {
        return '/home/quests';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/home/quests',
            builder: (context, state) => const QuestsTabScreen(),
          ),
          GoRoute(
            path: '/home/leaderboard',
            builder: (context, state) => const LeaderboardTabScreen(),
          ),
          GoRoute(
            path: '/home/shop',
            builder: (context, state) => const ShopTabScreen(),
          ),
          GoRoute(
            path: '/home/history',
            builder: (context, state) => const HistoryTabScreen(),
          ),
          GoRoute(
            path: '/home/profile',
            builder: (context, state) => const ProfileTabScreen(),
          ),
          GoRoute(
            path: '/home/all-topics',
            builder: (context, state) => const AllTopicsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/player-setup',
        builder: (context, state) => const PlayerSetupScreen(),
      ),
      GoRoute(
        path: '/create-room',
        builder: (context, state) => const CreateRoomScreen(),
      ),
      GoRoute(
        path: '/join-quest',
        builder: (context, state) => const JoinRoomScreen(),
      ),
      GoRoute(
        path: '/browse-quests',
        builder: (context, state) => const BrowseQuestsScreen(),
      ),
      GoRoute(
        path: '/lobby/:roomId',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId'] ?? '';
          return LobbyScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: '/quiz/:roomId',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId'] ?? '';
          return QuizPlayScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: '/live-monitoring/:roomId',
        builder: (context, state) {
          final roomId = state.pathParameters['roomId'] ?? '';
          return LiveMonitoringScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: '/create-quiz',
        builder: (context, state) => const CreateQuizScreen(),
      ),
      GoRoute(
        path: '/quiz-detail',
        builder: (context, state) {
          final quiz = state.extra as QuizSet;
          return QuizDetailScreen(quiz: quiz);
        },
      ),
      GoRoute(
        path: '/all-topics',
        builder: (context, state) => const AllTopicsScreen(),
      ),
    ],
  );
}
