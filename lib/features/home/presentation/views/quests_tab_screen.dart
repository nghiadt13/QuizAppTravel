import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../quest_room/presentation/viewmodels/create_room_view_model.dart';
import '../../../quest_room/presentation/viewmodels/join_room_view_model.dart';
import '../../../quiz/presentation/viewmodels/quiz_manager_view_model.dart';
import '../../../quiz/domain/entities/quiz_set.dart';

class QuestsTabScreen extends StatefulWidget {
  const QuestsTabScreen({super.key});

  @override
  State<QuestsTabScreen> createState() => _QuestsTabScreenState();
}

class _QuestsTabScreenState extends State<QuestsTabScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _float1;
  late final Animation<double> _float2;
  bool _isDarkPlaceholder = false;
  bool _isActionLoading = false;

  late final TextEditingController _pinController;
  late final FocusNode _pinFocusNode;
  late final TextEditingController _nicknameController;

  final List<Map<String, dynamic>> _topics = [
    {
      'title': 'Khám Phá Vũ Trụ',
      'dbTopic': 'Science & Technology',
      'questions': '8 Câu hỏi',
      'tag': 'Rất cuốn',
      'icon': Icons.rocket_launch,
      'color': const Color(0xFF5E35B1), // Purple
      'endColor': const Color(0xFF311B92),
    },
    {
      'title': 'Thần Đồng Công Nghệ',
      'dbTopic': 'Science & Technology',
      'questions': '10 Câu hỏi',
      'tag': 'Thực tế',
      'icon': Icons.laptop_chromebook,
      'color': const Color(0xFF0288D1), // Blue
      'endColor': const Color(0xFF01579B),
    },
    {
      'title': 'Sử Việt Hào Hùng',
      'dbTopic': 'History & Culture',
      'questions': '12 Câu hỏi',
      'tag': 'Hồi hộp',
      'icon': Icons.hourglass_bottom,
      'color': const Color(0xFF8D6E63), // Brown
      'endColor': const Color(0xFF4E342E),
    },
    {
      'title': 'Thế Giới Tự Nhiên',
      'dbTopic': 'Geography & Nature',
      'questions': '6 Câu hỏi',
      'tag': 'Thú vị',
      'icon': Icons.spa_outlined,
      'color': const Color(0xFF2E7D32), // Green
      'endColor': const Color(0xFF1B5E20),
    },
  ];

  @override
  void initState() {
    super.initState();

    // Bobbing float animation for background icons
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _float1 = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _float2 = Tween<double>(begin: 8.0, end: -8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pinController = TextEditingController();
    _pinFocusNode = FocusNode();
    _nicknameController = TextEditingController();

    _pinController.addListener(() {
      if (_pinController.text.length == 6) {
        _joinGameRoom(_pinController.text, Theme.of(context).colorScheme);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      if (authVm.currentUser != null) {
        context.read<QuizManagerViewModel>().fetchMyQuizzes(
          authVm.currentUser!.uid,
        );
      }
      context.read<QuizManagerViewModel>().fetchPublicQuizzes();
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pinController.dispose();
    _pinFocusNode.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _joinGameRoom(String pin, ColorScheme colors) async {
    if (pin.length != 6) return;

    final authVm = context.read<AuthViewModel>();
    final user = authVm.currentUser;

    String displayName = 'Bạn học mẫn cán';
    String avatarId = 'fox';
    String playerId;

    if (user != null) {
      displayName = user.displayName;
      avatarId = user.avatarUrl ?? 'fox';
      playerId = user.uid;
    } else {
      final typedName = _nicknameController.text.trim();
      if (typedName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập biệt danh để tham gia phòng.'),
            backgroundColor: Colors.orange,
          ),
        );
        _pinController.clear();
        _pinFocusNode.unfocus();
        return;
      }
      displayName = typedName;
      playerId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    }

    // Set loading
    setState(() => _isActionLoading = true);

    try {
      final joinVm = context.read<JoinRoomViewModel>();
      final room = await joinVm.joinRoom(
        pinCode: pin,
        displayName: displayName,
        avatarId: avatarId,
        playerId: playerId,
      );

      if (mounted) {
        if (room != null) {
          context.go('/lobby/${room.id}');
        } else {
          setState(() => _isActionLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                joinVm.errorMessage ??
                    'Mã PIN không đúng hoặc phòng đã bắt đầu chơi.',
              ),
              backgroundColor: colors.error,
            ),
          );
          _pinController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  Future<void> _startPracticeRoomWithQuiz(
    QuizSet quiz,
    ColorScheme colors,
  ) async {
    final authVm = context.read<AuthViewModel>();
    final user = authVm.currentUser;

    final hostId =
        user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

    setState(() => _isActionLoading = true);

    try {
      final createVm = context.read<CreateRoomViewModel>();
      createVm.selectQuiz(quiz.id, quiz.title);
      createVm.toggleIsPublic(true);
      final room = await createVm.createRoom(hostId);

      if (mounted) {
        if (room != null) {
          context.go('/lobby/${room.id}');
        } else {
          setState(() => _isActionLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                createVm.errorMessage ?? 'Không thể tạo phòng luyện tập.',
              ),
              backgroundColor: colors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isActionLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  Future<void> _startPracticeRoom(String topic, ColorScheme colors) async {
    final authVm = context.read<AuthViewModel>();
    final user = authVm.currentUser;

    final hostId =
        user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

    setState(() => _isActionLoading = true);

    try {
      final createVm = context.read<CreateRoomViewModel>();
      createVm.setTopic(topic);
      createVm.toggleIsPublic(true);
      final room = await createVm.createRoom(hostId);

      if (mounted) {
        if (room != null) {
          context.go('/lobby/${room.id}');
        } else {
          setState(() => _isActionLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                createVm.errorMessage ?? 'Không thể tạo phòng luyện tập.',
              ),
              backgroundColor: colors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isActionLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  void _selectRandomTopic(ColorScheme colors) {
    final quizVm = context.read<QuizManagerViewModel>();
    if (quizVm.publicQuizzes.isNotEmpty) {
      final random = Random();
      final selected =
          quizVm.publicQuizzes[random.nextInt(quizVm.publicQuizzes.length)];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎲 Chọn ngẫu nhiên: ${selected.title}!'),
          backgroundColor: colors.primary,
          duration: const Duration(seconds: 1),
        ),
      );

      _startPracticeRoomWithQuiz(selected, colors);
    } else {
      final random = Random();
      final selected = _topics[random.nextInt(_topics.length)];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎲 Chọn ngẫu nhiên: ${selected['title']}!'),
          backgroundColor: colors.primary,
          duration: const Duration(seconds: 1),
        ),
      );

      _startPracticeRoom(selected['dbTopic'], colors);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authVm = context.watch<AuthViewModel>();
    final quizVm = context.watch<QuizManagerViewModel>();
    final user = authVm.currentUser;
    final String displayName = user?.displayName ?? 'Bạn học mẫn cán';
    final String avatarUrl = user?.avatarUrl ?? 'fox';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: InkWell(
          onTap: () => context.go('/home/profile'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    _buildAvatar(avatarUrl, colors, displayName: displayName),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E), // Green online status
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.surface, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Xin chào,',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit_outlined,
                          size: 13,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                _isDarkPlaceholder
                    ? Icons.wb_sunny_outlined
                    : Icons.dark_mode_outlined,
                size: 20,
              ),
              color: AppColors.primary,
              onPressed: () {
                setState(() {
                  _isDarkPlaceholder = !_isDarkPlaceholder;
                });
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chế độ tối sẽ sớm được cập nhật! 🌙'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.emoji_events_outlined, size: 20),
              color: AppColors.primary,
              onPressed: () {
                context.go('/home/leaderboard');
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient Circles
          Positioned(
            left: -80,
            top: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: 0.03),
              ),
            ),
          ),
          Positioned(
            right: -100,
            bottom: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.secondaryContainer.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Background Bubbles Effect
          const Positioned.fill(child: AnimatedBubbles()),

          // Floating Background Icons
          AnimatedBuilder(
            animation: _float1,
            builder: (context, child) {
              return Positioned(
                left: 40,
                top: 150 + _float1.value,
                child: Transform.rotate(
                  angle: -0.15,
                  child: Icon(
                    Icons.flight_takeoff_outlined,
                    size: 80,
                    color: colors.primary.withValues(alpha: 0.04),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _float2,
            builder: (context, child) {
              return Positioned(
                right: 40,
                top: 220 + _float2.value,
                child: Transform.rotate(
                  angle: 0.2,
                  child: Icon(
                    Icons.map_outlined,
                    size: 75,
                    color: colors.primary.withValues(alpha: 0.04),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _float1,
            builder: (context, child) {
              return Positioned(
                left: 50,
                bottom: 120 + _float1.value,
                child: Transform.rotate(
                  angle: 0.1,
                  child: Icon(
                    Icons.star_outline,
                    size: 70,
                    color: colors.primary.withValues(alpha: 0.04),
                  ),
                ),
              );
            },
          ),

          // Main Scrollable Interactive Interface
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ----------------------------------------------------
                        // SECTION 1: Join Game Room Card (THAM GIA PHÒNG GAME)
                        // ----------------------------------------------------
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00475E), // AppColors.primary
                                Color(0xFF0C6B8A), // Synchronized Blue
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'THAM GIA PHÒNG GAME',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Nhập mã PIN để đối đầu trực tiếp cùng bạn bè.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Nickname input field ONLY for guest (not logged in)
                              if (user == null) ...[
                                TextField(
                                  controller: _nicknameController,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Biệt danh của bạn',
                                    labelStyle: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    hintText: 'Nhập biệt danh để tham gia...',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                      color: Colors.white70,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withValues(
                                      alpha: 0.08,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.secondaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // 6 PIN inputs row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(6, (index) {
                                  final text = _pinController.text;
                                  final char = text.length > index
                                      ? text[index]
                                      : '';
                                  final isFocused =
                                      _pinFocusNode.hasFocus &&
                                      text.length == index;

                                  return GestureDetector(
                                    onTap: () {
                                      _pinFocusNode.requestFocus();
                                    },
                                    child: Container(
                                      width: 44,
                                      height: 48,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isFocused
                                              ? AppColors
                                                    .secondaryContainer // Sunny Yellow
                                              : Colors.white.withValues(
                                                  alpha: 0.2,
                                                ),
                                          width: isFocused ? 2 : 1,
                                        ),
                                      ),
                                      child: Text(
                                        char,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),

                              // Bulletproof Hidden Input (6 digits)
                              SizedBox(
                                width: 0.1,
                                height: 0.1,
                                child: TextField(
                                  controller: _pinController,
                                  focusNode: _pinFocusNode,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  showCursor: false,
                                  style: const TextStyle(
                                    color: Colors.transparent,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    counterText: '',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Enter button (Vibrant Sunny Yellow)
                              ElevatedButton(
                                onPressed: () =>
                                    _joinGameRoom(_pinController.text, colors),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors
                                      .secondaryContainer, // Sunny Yellow
                                  foregroundColor:
                                      AppColors.onSecondaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 2,
                                  shadowColor: Colors.black26,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.rocket_launch, size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      'VÀO ĐẤU TRƯỜNG',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ----------------------------------------------------
                        // SECTION 2: Practice Topics (CHỦ ĐỀ TỰ LUYỆN TẬP)
                        // ----------------------------------------------------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CHỦ ĐỀ TỰ LUYỆN TẬP',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            InkWell(
                              onTap: () => _selectRandomTopic(colors),
                              child: Row(
                                children: [
                                  Text(
                                    'Chọn ngẫu nhiên 🎲',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colors.primary.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Practice Topics Grid (Real Public Quizzes from Firestore or Fallback)
                        if (quizVm.isLoading && quizVm.publicQuizzes.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (quizVm.publicQuizzes.isNotEmpty)
                          GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.95,
                                ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: quizVm.publicQuizzes.length,
                            itemBuilder: (context, index) {
                              final quiz = quizVm.publicQuizzes[index];
                              return _buildPublicQuizCard(quiz, index, colors);
                            },
                          )
                        else
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.95,
                            children: _topics
                                .map((topic) => _buildTopicCard(topic, colors))
                                .toList(),
                          ),
                        const SizedBox(height: 32),

                        // ----------------------------------------------------
                        // SECTION 3: Create Room Card (TỔ CHỨC PHÒNG GAME)
                        // ----------------------------------------------------
                        Text(
                          'TỔ CHỨC PHÒNG GAME',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.08),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.03),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colors.primary.withValues(
                                        alpha: 0.08,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.campaign_outlined,
                                      color: colors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Tạo phòng game mới',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tự tổ chức phòng thi đấu riêng, chọn chủ đề yêu thích và chia sẻ mã PIN để mời bạn bè cùng tham gia tranh tài.',
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () => context.push('/create-room'),
                                icon: const Icon(Icons.add),
                                label: const Text(
                                  'Tạo Phòng Game',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ----------------------------------------------------
                        // SECTION 4: Custom Quiz Creator (SÁNG TẠO BỘ CÂU HỎI)
                        // ----------------------------------------------------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SÁNG TẠO BỘ CÂU HỎI',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Miễn phí',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Banner Card for Creating Quiz
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryContainer,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryContainer
                                          .withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome,
                                      color: AppColors.secondaryContainer,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tự tạo Bộ Quiz của riêng bạn',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Tự do soạn câu hỏi & câu trả lời',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Bạn có thể tự tay tạo bộ câu hỏi trắc nghiệm tùy chỉnh, thêm ảnh minh họa, đặt thời gian trả lời và sử dụng để mở phòng game đấu hoặc chia sẻ cho cộng đồng!',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  final authVm = context.read<AuthViewModel>();
                                  final user = authVm.currentUser;
                                  final userId =
                                      user?.uid ??
                                      'guest_${DateTime.now().millisecondsSinceEpoch}';
                                  context
                                      .read<QuizManagerViewModel>()
                                      .startNewQuiz(userId);
                                  context.push('/create-quiz');
                                },
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 20,
                                ),
                                label: const Text(
                                  'TẠO BỘ CÂU HỎI MỚI',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondaryContainer,
                                  foregroundColor:
                                      AppColors.onSecondaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // If user has personal quizzes, display "BỘ CÂU HỎI CỦA BẠN" row
                        if (quizVm.myQuizzes.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'BỘ CÂU HỎI CỦA BẠN (${quizVm.myQuizzes.length})',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              InkWell(
                                onTap: () => context.go('/home/profile'),
                                child: Text(
                                  'Quản lý tất cả >',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: quizVm.myQuizzes.length,
                              itemBuilder: (context, index) {
                                final quiz = quizVm.myQuizzes[index];
                                return GestureDetector(
                                  onTap: () =>
                                      context.push('/quiz-detail', extra: quiz),
                                  child: Container(
                                    width: 200,
                                    margin: const EdgeInsets.only(right: 14),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      image:
                                          quiz.imageUrl != null &&
                                              quiz.imageUrl!.isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                quiz.imageUrl!,
                                              ),
                                              fit: BoxFit.cover,
                                              colorFilter: ColorFilter.mode(
                                                Colors.black.withValues(
                                                  alpha: 0.45,
                                                ),
                                                BlendMode.darken,
                                              ),
                                            )
                                          : null,
                                      gradient:
                                          quiz.imageUrl == null ||
                                              quiz.imageUrl!.isEmpty
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFF0D9488),
                                                Color(0xFF115E59),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.08,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white24,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${quiz.questions.length} câu',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              quiz.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isActionLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.45),
              child: const Center(
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          'Đang khởi tạo phòng game...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic, ColorScheme colors) {
    return GestureDetector(
      onTap: () => _startPracticeRoom(topic['dbTopic'], colors),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [topic['color'], topic['endColor']],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: topic['color'].withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              top: -15,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(topic['icon'], color: Colors.white, size: 20),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        topic['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${topic['questions']} • ${topic['tag']}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublicQuizCard(QuizSet quiz, int index, ColorScheme colors) {
    final styleIndex = index % _topics.length;
    final style = _topics[styleIndex];

    return GestureDetector(
      onTap: () => context.push('/quiz-detail', extra: quiz),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          image: quiz.imageUrl != null && quiz.imageUrl!.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(quiz.imageUrl!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.45),
                    BlendMode.darken,
                  ),
                )
              : null,
          gradient: quiz.imageUrl == null || quiz.imageUrl!.isEmpty
              ? LinearGradient(
                  colors: [style['color'], style['endColor']],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (style['color'] as Color).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              top: -15,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(style['icon'], color: Colors.white, size: 20),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${quiz.questions.length} câu hỏi • Công khai',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl, ColorScheme colors, {String? displayName}) {
    return AppAvatar(
      avatarUrl: avatarUrl,
      displayName: displayName,
      radius: 20,
    );
  }
}

class AnimatedBubbles extends StatefulWidget {
  const AnimatedBubbles({super.key});

  @override
  State<AnimatedBubbles> createState() => _AnimatedBubblesState();
}

class _AnimatedBubblesState extends State<AnimatedBubbles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Bubble> _bubbles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Initialize 15 bubbles with random values (slightly fewer for subtlety)
    for (int i = 0; i < 15; i++) {
      _bubbles.add(
        Bubble(
          x: _random.nextDouble(),
          y: _random.nextDouble() * 1.2, // Spread out vertically
          size: _random.nextDouble() * 7 + 3, // size 3 to 10
          speed: _random.nextDouble() * 0.0006 + 0.0003, // Slower float speed
          opacity: _random.nextDouble() * 0.08 + 0.03, // Translucent opacity
          swaySpeed: _random.nextDouble() * 0.8 + 0.4, // Slower swaying motion
          swayWidth: _random.nextDouble() * 8 + 2, // Gentler swaying width
        ),
      );
    }

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..addListener(_updateBubbles)
          ..repeat();
  }

  void _updateBubbles() {
    if (!mounted) return;
    setState(() {
      for (var bubble in _bubbles) {
        bubble.y -= bubble.speed;
        if (bubble.y < -0.1) {
          // Reset to bottom once it floats out of view
          bubble.y = 1.1;
          bubble.x = _random.nextDouble();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubblePainter(
        bubbles: _bubbles,
        colors: Theme.of(context).colorScheme,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class Bubble {
  double x; // Horizontal percentage (0.0 to 1.0)
  double y; // Vertical percentage (0.0 to 1.0)
  final double size;
  final double speed;
  final double opacity;
  final double swaySpeed;
  final double swayWidth;
  double time = 0.0;

  Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.swaySpeed,
    required this.swayWidth,
  });
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final ColorScheme colors;

  BubblePainter({required this.bubbles, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var bubble in bubbles) {
      // Sway left/right based on sine wave
      bubble.time += 0.016; // Simulate delta time
      final double sway =
          sin(bubble.time * bubble.swaySpeed) * bubble.swayWidth;

      final double actualX = bubble.x * size.width + sway;
      final double actualY = bubble.y * size.height;

      // Draw bubble base
      paint.color = colors.primary.withValues(alpha: bubble.opacity);
      canvas.drawCircle(Offset(actualX, actualY), bubble.size, paint);

      // Draw bubble specular highlight (reflecting light on top-left)
      paint.color = Colors.white.withValues(alpha: bubble.opacity * 1.8);
      canvas.drawCircle(
        Offset(actualX - bubble.size * 0.3, actualY - bubble.size * 0.3),
        bubble.size * 0.22,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
