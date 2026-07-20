import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../quest_room/presentation/viewmodels/create_room_view_model.dart';
import '../../domain/entities/quiz_set.dart';
import '../viewmodels/quiz_manager_view_model.dart';

class AllTopicsScreen extends StatefulWidget {
  const AllTopicsScreen({super.key});

  @override
  State<AllTopicsScreen> createState() => _AllTopicsScreenState();
}

class _AllTopicsScreenState extends State<AllTopicsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  bool _isActionLoading = false;

  final List<String> _categories = [
    'Tất cả',
    'Khoa học',
    'Công nghệ',
    'Lịch sử',
    'Du lịch',
    'Giải trí',
  ];

  final List<Map<String, dynamic>> _fallbackTopics = [
    {
      'title': 'Khám Phá Vũ Trụ',
      'dbTopic': 'Science & Technology',
      'questions': '8 Câu hỏi',
      'tag': 'Rất cuốn',
      'icon': Icons.rocket_launch,
      'color': const Color(0xFF5E35B1),
      'endColor': const Color(0xFF311B92),
    },
    {
      'title': 'Thần Đồng Công Nghệ',
      'dbTopic': 'Science & Technology',
      'questions': '10 Câu hỏi',
      'tag': 'Thực tế',
      'icon': Icons.laptop_chromebook,
      'color': const Color(0xFF0288D1),
      'endColor': const Color(0xFF01579B),
    },
    {
      'title': 'Sử Việt Hào Hùng',
      'dbTopic': 'History & Culture',
      'questions': '12 Câu hỏi',
      'tag': 'Hồi hộp',
      'icon': Icons.hourglass_bottom,
      'color': const Color(0xFF8D6E63),
      'endColor': const Color(0xFF4E342E),
    },
    {
      'title': 'Thế Giới Tự Nhiên',
      'dbTopic': 'Geography & Nature',
      'questions': '6 Câu hỏi',
      'tag': 'Thú vị',
      'icon': Icons.spa_outlined,
      'color': const Color(0xFF2E7D32),
      'endColor': const Color(0xFF1B5E20),
    },
    {
      'title': 'Văn hóa & Địa lý Việt Nam',
      'dbTopic': 'Travel & Geography',
      'questions': '25 Câu hỏi',
      'tag': 'Hot',
      'icon': Icons.explore,
      'color': const Color(0xFFE65100),
      'endColor': const Color(0xFFBF360C),
    },
    {
      'title': 'Lập trình & Backend',
      'dbTopic': 'Science & Technology',
      'questions': '25 Câu hỏi',
      'tag': 'Pro',
      'icon': Icons.code,
      'color': const Color(0xFF1A237E),
      'endColor': const Color(0xFF0D47A1),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizManagerViewModel>().fetchPublicQuizzes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      createVm.toggleIsPublic(false);
      final room = await createVm.createRoom(hostId);

      if (mounted) {
        if (room != null) {
          context.go('/quiz/${room.id}');
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
      createVm.toggleIsPublic(false);
      final room = await createVm.createRoom(hostId);

      if (mounted) {
        if (room != null) {
          context.go('/quiz/${room.id}');
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final quizVm = context.watch<QuizManagerViewModel>();
    final query = _searchController.text.trim().toLowerCase();

    // Filter public quizzes
    final filteredQuizzes = quizVm.publicQuizzes.where((quiz) {
      final matchesSearch =
          query.isEmpty ||
          quiz.title.toLowerCase().contains(query) ||
          quiz.description.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == 'Tất cả' ||
          quiz.title.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
          quiz.description.toLowerCase().contains(_selectedCategory.toLowerCase());

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Tất Cả Chủ Đề & Quiz 📚',
          style: AppTextStyles.headlineMedium.copyWith(color: colors.primary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.primary, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colors.primary),
            onPressed: () => quizVm.fetchPublicQuizzes(),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm bộ quiz, chủ đề...',
                      hintStyle: TextStyle(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.search, color: colors.primary),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: colors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: colors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // Category Chips
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : colors.primary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: colors.primary,
                          backgroundColor: Colors.white,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? colors.primary
                                  : colors.primary.withValues(alpha: 0.15),
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Quiz Grid
                Expanded(
                  child: quizVm.isLoading && quizVm.publicQuizzes.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : filteredQuizzes.isNotEmpty
                          ? GridView.builder(
                              padding: const EdgeInsets.all(20),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.92,
                              ),
                              itemCount: filteredQuizzes.length,
                              itemBuilder: (context, index) {
                                final quiz = filteredQuizzes[index];
                                return _buildPublicQuizCard(quiz, index, colors);
                              },
                            )
                          : (quizVm.publicQuizzes.isEmpty
                              ? GridView.count(
                                  padding: const EdgeInsets.all(20),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.92,
                                  children: _fallbackTopics
                                      .map((topic) =>
                                          _buildTopicCard(topic, colors))
                                      .toList(),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 64,
                                        color: colors.primary
                                            .withValues(alpha: 0.3),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Không tìm thấy chủ đề nào',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: colors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Thử tìm kiếm với từ khóa khác nhé.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colors.onSurfaceVariant
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (_isActionLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.45),
              child: const Center(
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          'Đang khởi tạo phòng luyện tập...',
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

  Widget _buildPublicQuizCard(QuizSet quiz, int index, ColorScheme colors) {
    final List<List<Color>> gradients = [
      [const Color(0xFF5E35B1), const Color(0xFF311B92)],
      [const Color(0xFF0288D1), const Color(0xFF01579B)],
      [const Color(0xFF8D6E63), const Color(0xFF4E342E)],
      [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
      [const Color(0xFFD81B60), const Color(0xFF880E4F)],
      [const Color(0xFFF57C00), const Color(0xFFE65100)],
    ];
    final gradient = gradients[index % gradients.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _startPracticeRoomWithQuiz(quiz, colors),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.quiz_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Công khai',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${quiz.questions.length} câu hỏi',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic, ColorScheme colors) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _startPracticeRoom(topic['dbTopic'], colors),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [topic['color'], topic['endColor']],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (topic['color'] as Color).withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        topic['icon'] as IconData,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        topic['tag'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic['questions'],
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
