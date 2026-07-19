import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../router/app_router.dart';

// Auth Feature imports
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/mappers/host_user_mapper.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/application/services/i_auth_service.dart';
import '../../features/auth/application/services/auth_service_impl.dart';
import '../../features/auth/presentation/viewmodels/auth_view_model.dart';
import '../../features/home/presentation/viewmodels/profile_view_model.dart';

// Quest Room Feature imports
import '../../features/quest_room/data/datasources/preset_avatar_data_source.dart';
import '../../features/quest_room/data/datasources/quest_room_remote_data_source.dart';
import '../../features/quest_room/data/mappers/preset_avatar_mapper.dart';
import '../../features/quest_room/data/mappers/quest_room_mapper.dart';
import '../../features/quest_room/data/mappers/participant_mapper.dart';
import '../../features/quest_room/data/repositories/quest_room_repository_impl.dart';
import '../../features/quest_room/domain/repositories/i_quest_room_repository.dart';
import '../../features/quest_room/application/services/i_quest_room_service.dart';
import '../../features/quest_room/application/services/quest_room_service_impl.dart';
import '../../features/quest_room/presentation/viewmodels/player_setup_view_model.dart';
import '../../features/quest_room/presentation/viewmodels/create_room_view_model.dart';
import '../../features/quest_room/presentation/viewmodels/join_room_view_model.dart';
import '../../features/quest_room/presentation/viewmodels/browse_quests_view_model.dart';
import '../../features/quest_room/presentation/viewmodels/lobby_view_model.dart';

// Quiz Feature imports
import '../../features/quiz_game/data/datasources/quiz_remote_data_source.dart';
import '../../features/quiz_game/data/mappers/quiz_question_mapper.dart';
import '../../features/quiz_game/data/repositories/quiz_repository_impl.dart';
import '../../features/quiz_game/domain/repositories/i_quiz_repository.dart';
import '../../features/quiz_game/application/services/i_quiz_service.dart';
import '../../features/quiz_game/application/services/quiz_service_impl.dart';
import '../../features/quiz_game/presentation/viewmodels/quiz_play_view_model.dart';
import '../../features/quiz/data/datasources/quiz_manager_remote_data_source.dart';
import '../../features/quiz/data/mappers/quiz_mapper.dart';
import '../../features/quiz/data/repositories/quiz_manager_repository_impl.dart';
import '../../features/quiz/domain/repositories/i_quiz_manager_repository.dart';
import '../../features/quiz/application/services/i_quiz_manager_service.dart';
import '../../features/quiz/application/services/quiz_manager_service_impl.dart';
import '../../features/quiz/presentation/viewmodels/quiz_manager_view_model.dart';

// Live Monitoring Feature imports
import '../../features/live_monitoring/data/datasources/monitoring_remote_data_source.dart';
import '../../features/live_monitoring/data/mappers/player_live_status_mapper.dart';
import '../../features/live_monitoring/data/repositories/monitoring_repository_impl.dart';
import '../../features/live_monitoring/domain/repositories/i_monitoring_repository.dart';
import '../../features/live_monitoring/application/services/i_monitoring_service.dart';
import '../../features/live_monitoring/application/services/monitoring_service_impl.dart';
import '../../features/live_monitoring/presentation/viewmodels/host_control_view_model.dart';

// Reward Feature imports
import '../../features/reward/data/datasources/reward_remote_data_source.dart';
import '../../features/reward/data/mappers/travel_reward_mapper.dart';
import '../../features/reward/data/repositories/reward_repository_impl.dart';
import '../../features/reward/domain/repositories/i_reward_repository.dart';
import '../../features/reward/application/services/i_reward_service.dart';
import '../../features/reward/application/services/reward_service_impl.dart';
import '../../features/reward/presentation/viewmodels/open_chest_view_model.dart';

// Leaderboard Feature imports
import '../../features/leaderboard/data/datasources/leaderboard_remote_data_source.dart';
import '../../features/leaderboard/data/mappers/leaderboard_entry_mapper.dart';
import '../../features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import '../../features/leaderboard/domain/repositories/i_leaderboard_repository.dart';
import '../../features/leaderboard/application/services/i_leaderboard_service.dart';
import '../../features/leaderboard/application/services/leaderboard_service_impl.dart';
import '../../features/leaderboard/presentation/viewmodels/leaderboard_view_model.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // ==========================================
  // 1. External / Firebase Services
  // ==========================================
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // GoogleSignIn SDK: only initialize on non-web platforms.
  // On web, auth uses Firebase signInWithPopup directly (see auth_remote_data_source.dart).
  if (!kIsWeb) {
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      clientId: '58793994198-0fr6me63al9ohipl3idp41dtqa632p3q.apps.googleusercontent.com',
    );
    getIt.registerLazySingleton<GoogleSignIn>(() => googleSignIn);
  } else {
    // Register a no-op instance for web so GetIt doesn't fail
    getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
  }

  // Router
  getIt.registerLazySingleton<AppRouter>(() => AppRouter());

  // ==========================================
  // 2. Feature: Auth
  // ==========================================
  // Mapper
  getIt.registerLazySingleton<HostUserMapper>(() => HostUserMapper());

  // Data Sources
  getIt.registerLazySingleton<IAuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt(), getIt(), getIt()),
  );
  
  // Repositories
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );

  // Application Services
  getIt.registerLazySingleton<IAuthService>(
    () => AuthServiceImpl(getIt()),
  );

  // ViewModels
  getIt.registerLazySingleton<AuthViewModel>(() => AuthViewModel(getIt()));

  // ==========================================
  // 3. Feature: Quiz
  // ==========================================
  // Mappers
  getIt.registerLazySingleton<QuizQuestionMapper>(() => QuizQuestionMapper());
  getIt.registerLazySingleton<QuizMapper>(() => QuizMapper());

  // Data Sources
  getIt.registerLazySingleton<IQuizRemoteDataSource>(
    () => QuizRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<IQuizManagerRemoteDataSource>(
    () => QuizManagerRemoteDataSourceImpl(getIt()),
  );
  
  // Repositories
  getIt.registerLazySingleton<IQuizRepository>(
    () => QuizRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<IQuizManagerRepository>(
    () => QuizManagerRepositoryImpl(getIt(), getIt()),
  );

  // Services
  getIt.registerLazySingleton<IQuizService>(
    () => QuizServiceImpl(getIt()),
  );
  getIt.registerLazySingleton<IQuizManagerService>(
    () => QuizManagerServiceImpl(getIt()),
  );

  // ViewModels
  getIt.registerFactory(() => QuizPlayViewModel(getIt()));
  getIt.registerFactory(() => QuizManagerViewModel(getIt()));

  // ==========================================
  // 4. Feature: Reward
  // ==========================================
  // Data Sources
  // getIt.registerLazySingleton<TravelRemoteDataSource>(() => TravelRemoteDataSource(getIt()));
  
  // Repositories
  // getIt.registerLazySingleton<ITravelRepository>(() => TravelRepositoryImpl(getIt()));

  // ViewModels
  // getIt.registerFactory(() => TravelViewModel(getIt()));

  // ==========================================
  // 5. Feature: Quest Room
  // ==========================================
  // Mappers
  getIt.registerLazySingleton<PresetAvatarMapper>(() => PresetAvatarMapper());
  getIt.registerLazySingleton<QuestRoomMapper>(() => QuestRoomMapper());
  getIt.registerLazySingleton<ParticipantMapper>(() => ParticipantMapper());

  // Data Sources
  getIt.registerLazySingleton<IPresetAvatarDataSource>(
    () => PresetAvatarDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<IQuestRoomRemoteDataSource>(
    () => QuestRoomRemoteDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<IQuestRoomRepository>(
    () => QuestRoomRepositoryImpl(
      getIt(),
      getIt(),
      getIt(),
      getIt(),
      getIt(),
    ),
  );

  // Services
  getIt.registerLazySingleton<IQuestRoomService>(
    () => QuestRoomServiceImpl(getIt()),
  );

  // ViewModels
  getIt.registerFactory(() => PlayerSetupViewModel(getIt()));
  getIt.registerFactory(() => CreateRoomViewModel(getIt()));
  getIt.registerFactory(() => JoinRoomViewModel(getIt()));
  getIt.registerFactory(() => BrowseQuestsViewModel(getIt()));
  getIt.registerFactory(() => LobbyViewModel(getIt()));

  // ==========================================
  // Feature: Live Monitoring
  // ==========================================
  // Mappers
  getIt.registerLazySingleton<PlayerLiveStatusMapper>(() => PlayerLiveStatusMapper());

  // Data Sources
  getIt.registerLazySingleton<IMonitoringRemoteDataSource>(
    () => MonitoringRemoteDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<IMonitoringRepository>(
    () => MonitoringRepositoryImpl(getIt(), getIt()),
  );

  // Services
  getIt.registerLazySingleton<IMonitoringService>(
    () => MonitoringServiceImpl(getIt()),
  );

  // ViewModels
  getIt.registerFactory(() => HostControlViewModel(getIt()));

  // ==========================================
  // Feature: Reward
  // ==========================================
  // Mappers
  getIt.registerLazySingleton<TravelRewardMapper>(() => TravelRewardMapper());

  // Data Sources
  getIt.registerLazySingleton<IRewardRemoteDataSource>(
    () => RewardRemoteDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<IRewardRepository>(
    () => RewardRepositoryImpl(getIt(), getIt()),
  );

  // Services
  getIt.registerLazySingleton<IRewardService>(
    () => RewardServiceImpl(getIt()),
  );

  // ViewModels
  getIt.registerFactory(() => OpenChestViewModel(getIt()));

  // ==========================================
  // Feature: Leaderboard
  // ==========================================
  // Mappers
  getIt.registerLazySingleton<LeaderboardEntryMapper>(() => LeaderboardEntryMapper());

  // Data Sources
  getIt.registerLazySingleton<ILeaderboardRemoteDataSource>(
    () => LeaderboardRemoteDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<ILeaderboardRepository>(
    () => LeaderboardRepositoryImpl(getIt(), getIt()),
  );

  // Services
  getIt.registerLazySingleton<ILeaderboardService>(
    () => LeaderboardServiceImpl(getIt()),
  );

  // ViewModels
  getIt.registerFactory(() => LeaderboardViewModel(getIt()));
  getIt.registerFactory(() => ProfileViewModel(getIt(), getIt()));
}
