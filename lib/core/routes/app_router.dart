import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/views/join_quest_view.dart';
import '../../features/quiz/presentation/views/host_waiting_room_view.dart';
import '../../features/quiz/presentation/views/host_progress_view.dart';
import '../../features/quiz/presentation/views/question_view.dart';
import '../../features/quiz/presentation/views/leaderboard_view.dart';
import '../navigation/main_layout_view.dart';
import '../../main.dart'; // For WelcomeScreen

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/join',
      name: 'join',
      builder: (context, state) => const JoinQuestView(),
    ),
    GoRoute(
      path: '/host-waiting',
      name: 'host_waiting',
      builder: (context, state) => const HostWaitingRoomView(),
    ),
    GoRoute(
      path: '/host-progress',
      name: 'host_progress',
      builder: (context, state) => const HostProgressView(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayoutView(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/question',
              name: 'question',
              builder: (context, state) => const QuestionView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/leaderboard',
              name: 'leaderboard',
              builder: (context, state) => const LeaderboardView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/passport',
              name: 'passport',
              builder: (context, state) => const PlaceholderView(title: 'Passport'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/shop',
              name: 'shop',
              builder: (context, state) => const PlaceholderView(title: 'Shop'),
            ),
          ],
        ),
      ],
    ),
  ],
);

class PlaceholderView extends StatelessWidget {
  final String title;
  const PlaceholderView({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text(title)));
  }
}
