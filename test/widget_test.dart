import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_app_travel/core/di/di.dart';
import 'package:quiz_app_travel/core/router/app_router.dart';
import 'package:quiz_app_travel/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:quiz_app_travel/features/auth/application/services/i_auth_service.dart';
import 'package:quiz_app_travel/features/quest_room/presentation/viewmodels/player_setup_view_model.dart';
import 'package:quiz_app_travel/features/quest_room/application/services/i_quest_room_service.dart';
import 'package:quiz_app_travel/features/quest_room/presentation/viewmodels/create_room_view_model.dart';
import 'package:quiz_app_travel/features/quest_room/presentation/viewmodels/join_room_view_model.dart';
import 'package:quiz_app_travel/features/quest_room/presentation/viewmodels/browse_quests_view_model.dart';
import 'package:quiz_app_travel/features/quest_room/presentation/viewmodels/lobby_view_model.dart';
import 'package:quiz_app_travel/features/quiz_game/presentation/viewmodels/quiz_play_view_model.dart';
import 'package:quiz_app_travel/features/quiz_game/application/services/i_quiz_service.dart';
import 'package:quiz_app_travel/features/live_monitoring/presentation/viewmodels/host_control_view_model.dart';
import 'package:quiz_app_travel/features/live_monitoring/application/services/i_monitoring_service.dart';
import 'package:quiz_app_travel/features/reward/presentation/viewmodels/open_chest_view_model.dart';
import 'package:quiz_app_travel/features/reward/application/services/i_reward_service.dart';
import 'package:quiz_app_travel/features/leaderboard/presentation/viewmodels/leaderboard_view_model.dart';
import 'package:quiz_app_travel/features/leaderboard/application/services/i_leaderboard_service.dart';
import 'package:quiz_app_travel/main.dart';

class MockAuthService extends Mock implements IAuthService {}
class MockQuestRoomService extends Mock implements IQuestRoomService {}
class MockQuizService extends Mock implements IQuizService {}
class MockMonitoringService extends Mock implements IMonitoringService {}
class MockRewardService extends Mock implements IRewardService {}
class MockLeaderboardService extends Mock implements ILeaderboardService {}

void setupTestDependencies() {
  getIt.reset();

  final mockAuthService = MockAuthService();
  final mockQuestRoomService = MockQuestRoomService();
  final mockQuizService = MockQuizService();
  final mockMonitoringService = MockMonitoringService();
  final mockRewardService = MockRewardService();
  final mockLeaderboardService = MockLeaderboardService();

  // Stub the authStateChanges stream since AuthViewModel listens to it on creation.
  when(() => mockAuthService.authStateChanges).thenAnswer((_) => const Stream.empty());

  getIt.registerFactory<AuthViewModel>(() => AuthViewModel(mockAuthService));
  getIt.registerFactory<PlayerSetupViewModel>(() => PlayerSetupViewModel(mockQuestRoomService));
  getIt.registerFactory<CreateRoomViewModel>(() => CreateRoomViewModel(mockQuestRoomService));
  getIt.registerFactory<JoinRoomViewModel>(() => JoinRoomViewModel(mockQuestRoomService));
  getIt.registerFactory<BrowseQuestsViewModel>(() => BrowseQuestsViewModel(mockQuestRoomService));
  getIt.registerFactory<LobbyViewModel>(() => LobbyViewModel(mockQuestRoomService));
  getIt.registerFactory<QuizPlayViewModel>(() => QuizPlayViewModel(mockQuizService));
  getIt.registerFactory<HostControlViewModel>(() => HostControlViewModel(mockMonitoringService));
  getIt.registerFactory<OpenChestViewModel>(() => OpenChestViewModel(mockRewardService));
  getIt.registerFactory<LeaderboardViewModel>(() => LeaderboardViewModel(mockLeaderboardService));

  getIt.registerLazySingleton<AppRouter>(() => AppRouter());
}

void main() {
  setUp(() {
    setupTestDependencies();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('App initialization and LoginScreen rendering test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the login screen renders and displays correct elements.
    expect(find.text('TravelQuest'), findsOneWidget);
    expect(find.text('Discover the world through knowledge'), findsOneWidget);
    expect(find.text('Host Control Panel'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Join a Quest Room (No Login)'), findsOneWidget);
  });
}
