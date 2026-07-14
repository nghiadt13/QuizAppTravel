# TravelQuest - Travel Trivia & Multiplayer Adventure Quiz

TravelQuest is a Flutter-based multiplayer travel trivia quiz application that connects travelers, quiz enthusiasts, and guides. Players can join custom-created rooms, test their geography/travel knowledge in interactive quizzes, claim rewards from treasure chests, and compete on dynamic leaderboards.

---

## 🏗️ Clean Architecture & MVVM Structure

The project is structured following a **Feature-First + Clean Architecture** combined with the **MVVM (Model-View-ViewModel)** design pattern. This pattern separates business logic, data, and presentation layers for each functional feature, maximizing code modularity, testability, and extensibility.

### Directory Layout

```text
lib/
├── main.dart                      # App entry point, initializes Firebase & DI
├── core/                          # Cross-cutting concerns shared across features
│   ├── di/                        # GetIt Dependency Injection config
│   ├── router/                    # GoRouter navigation paths
│   └── theme/                     # App colors, fonts, and theme definitions
└── features/                      # Modular features (Clean Architecture slices)
    └── <feature_name>/
        ├── domain/                # Pure Business Logic Layer (No framework imports)
        │   ├── entities/          # Pure Dart models representing business concepts
        │   └── repositories/      # Abstract interfaces defining data operation contracts
        ├── data/                  # Data Infrastructure Layer
        │   ├── datasources/       # Direct APIs / Firestore connectors
        │   ├── dtos/              # Data Transfer Objects reflecting database structure
        │   ├── mappers/           # Translates between DTOs and Domain Entities
        │   └── repositories/      # Concrete implementations of domain repositories
        ├── application/           # Application Business Logic Layer
        │   └── services/          # Services coordinating use-cases and scoring logic
        └── presentation/          # MVVM User Interface Layer
            ├── viewmodels/        # ChangeNotifier state managers injecting Services
            ├── views/             # Screen pages built as Flutter widgets
            └── widgets/           # Sub-widgets specific to the feature
```

### Dependency Flow

The architecture enforces a strict unidirectional dependency rule:
1. **Views** monitor and dispatch user actions to **ViewModels**.
2. **ViewModels** coordinate operations by invoking **Application Services**.
3. **Application Services** communicate with the **Domain Repository Interfaces**.
4. **Concrete Repositories** invoke **Remote/Local Data Sources** to retrieve data.
5. Data returned from data sources (as DTOs) is converted via **Mappers** into pure **Domain Entities** before moving back up the stack.

Dependency injection is managed centrally using GetIt in [di.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/core/di/di.dart).

---

## 🚀 Key Features Documentation

Here are the newly implemented core features of the TravelQuest application:

### 1. Host Authentication with Google Sign-in
* **Folder**: `lib/features/auth/`
* **Description**: Allows quest creators (hosts) to securely sign in using Google Sign-In, integrated directly with Firebase Authentication.
* **Key Components**:
  * [login_screen.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/auth/presentation/views/login_screen.dart): UI containing a styled landing screen and Google sign-in buttons.
  * [auth_view_model.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/auth/presentation/viewmodels/auth_view_model.dart): Manages the sign-in state, loading flags, and communicates user changes to GoRouter.
  * [auth_service_impl.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/auth/application/services/auth_service_impl.dart): Orchestrates OAuth credentials verification.
  * [auth_repository_impl.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/auth/data/repositories/auth_repository_impl.dart): Maps credentials to Firebase instances.
  * [auth_remote_data_source.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/auth/data/datasources/auth_remote_data_source.dart): Handles low-level interaction with the GoogleSignIn SDK and FirebaseAuth.
  * [host_user.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/auth/domain/entities/host_user.dart): Pure entity representing the authenticated host.

### 2. Quest Room Lobby
* **Folder**: `lib/features/quest_room/`
* **Description**: Handles the creation and connection of multiplayer quiz rooms. Players input a 6-digit PIN code to connect to the host's lobby, choose names, and pick 3D-styled travel avatars. Live player lists update reactively using Firestore database streams.
* **Key Components**:
  * [create_room_screen.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/quest_room/presentation/views/create_room_screen.dart): Let's the host name a room and set up topics.
  * [join_room_screen.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/quest_room/presentation/views/join_room_screen.dart): Includes individual field pin inputs for joining.
  * [player_setup_screen.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/quest_room/presentation/views/player_setup_screen.dart): UI to select names and preset travel avatars.
  * [lobby_screen.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/quest_room/presentation/views/lobby_screen.dart): Lists active, connected players real-time. Automatically routes players to the game when the host starts.
  * [quest_room.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/quest_room/domain/entities/quest_room.dart): Domain model defining the status, host, topic, and PIN of the room.

### 3. Browse Public Quests
* **Folder**: `lib/features/quest_room/`
* **Description**: Allows prospective players to look through a catalog of public quests and travel lobbies currently waiting for players.
* **Key Components**:
  * [browse_quests_screen.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/quest_room/presentation/views/browse_quests_screen.dart): Grid list of active, open public quests.
  * [browse_quests_view_model.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/quest_room/presentation/viewmodels/browse_quests_view_model.dart): Manages quest catalog state, filtering, and loading.

### 4. Quiz Game
* **Folder**: `lib/features/quiz_game/`
* **Description**: The core player gameplay experience. Delivers structured travel trivia. Includes a global countdown timer, point scoring (+150 for correct options), point deductions for hints (-50), and immediate slide-up toast feedback upon submitting.
* **Key Components**:
  * [quiz_play_screen.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/quiz_game/presentation/views/quiz_play_screen.dart): Renders the current question card, options, current star count, and navigation.
  * [countdown_timer.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/quiz_game/presentation/widgets/countdown_timer.dart): Reactive timer widget that triggers auto-submission when hitting zero.
  * [hint_button.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/quiz_game/presentation/widgets/hint_button.dart): Exposes a hint button which reveals details in exchange for a score penalty.
  * [question_card.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/quiz_game/presentation/widgets/question_card.dart): Visual module depicting the travel-related question and geographic visual tags.
  * [answer_option_tile.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/quiz_game/presentation/widgets/answer_option_tile.dart): Interactive tiles displaying options with responsive touch states.

### 5. Live Monitoring (Host Control Panel)
* **Folder**: `lib/features/live_monitoring/`
* **Description**: Gives hosts real-time supervision over the room's progression. Displays live-updating player status grids (rank, active questions, progress bars, response times, finished milestones) and game flow command structures.
* **Key Components**:
  * [live_monitoring_screen.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/live_monitoring/presentation/views/live_monitoring_screen.dart): Core stream listener that renders the status of all active room members.
  * [host_control_screen.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/live_monitoring/presentation/views/host_control_screen.dart): Host control panel containing live statistics and the main action bar.
  * [action_control_bar.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/live_monitoring/presentation/widgets/action_control_bar.dart): Admin controller containing "Start Game", "Next Question", "Pause Session", and "End Game" triggers.

### 6. Gift Chest Rewards
* **Folder**: `lib/features/reward/`
* **Description**: Playful post-game interactive screen where players can tap a 3D-styled treasure chest 3 times to reveal randomly selected rare travel vouchers, tickets, or badges, which they can save to their travel wallets.
* **Key Components**:
  * [open_chest_screen.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/reward/presentation/views/open_chest_screen.dart): Hosts the chest opening sequence.
  * [treasure_chest.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/reward/presentation/widgets/treasure_chest.dart): State-driven tap chest widget supporting click shake feedback.
  * [sparkle_particles.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/reward/presentation/widgets/sparkle_particles.dart): Custom painter rendering particle explosion sparks when the chest is hit or opened.
  * [reward_card.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/reward/presentation/widgets/reward_card.dart): Shows item classifications, codes, titles, and claims.

### 7. Leaderboards
* **Folder**: `lib/features/leaderboard/`
* **Description**: Renders game and seasonal standings. Includes podium blocks for the top 3, dynamic list components for general rankings, events banners for seasonal badges, and a user-sticky card anchored at the bottom highlighting the player's personal rank.
* **Key Components**:
  * [leaderboard_tab_screen.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/home/presentation/views/leaderboard_tab_screen.dart): Standings tab that queries global and local high scores.
  * [top_three_podium.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/leaderboard/presentation/widgets/top_three_podium.dart): Podium widget showing 1st, 2nd, and 3rd place with customized colors, crown animations, and trophies.
  * [ranked_list_item.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/leaderboard/presentation/widgets/ranked_list_item.dart): Flexible widgets for players ranked #4 and below.
  * [user_sticky_card.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/leaderboard/presentation/widgets/user_sticky_card.dart): A profile card pinned to the bottom of the list highlighting the current player's standing.
  * [season_reward_banner.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/features/leaderboard/presentation/widgets/season_reward_banner.dart): Promotes ongoing challenges and prize incentives.

---

## 🛠️ Getting Started

### 📋 Prerequisites
* Flutter SDK (>=3.0.0)
* Android Studio / Xcode / VS Code
* Firebase Project setup (including Firestore & Auth enabled)

### ⚙️ Installation
1. Clone the repository.
2. Run `flutter pub get` to download required dependencies.
3. Configure your Firebase project using the Flutterfire CLI. This generates [firebase_options.dart](file:///D:/Education/PRM393/QuizAppTravel/lib/firebase_options.dart) automatically.
4. Run the project on an emulator or active test device using:
   ```bash
   flutter run
   ```
