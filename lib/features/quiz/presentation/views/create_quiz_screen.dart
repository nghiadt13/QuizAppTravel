import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../quiz_game/domain/entities/quiz_question.dart';
import '../viewmodels/quiz_manager_view_model.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  String _selectedCover = '';
  bool _isPublic = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<QuizManagerViewModel>();
    final authVm = context.read<AuthViewModel>();
    final editing = vm.editingQuiz;
    final userEmail = authVm.currentUser?.email;
    final isAdmin = userEmail != null && userEmail.trim().toLowerCase() == 'll.stylish73@gmail.com';

    _titleController = TextEditingController(text: editing?.title ?? '');
    _descController = TextEditingController(text: editing?.description ?? '');
    _selectedCover = editing?.imageUrl ?? '';
    _isPublic = isAdmin ? (editing?.isPublic ?? false) : false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      // Get references before async operations
      final authVm = context.read<AuthViewModel>();
      final vm = context.read<QuizManagerViewModel>();
      final userId = authVm.currentUser?.uid ?? 'guest';

      setState(() => _isUploading = true);

      // Read image bytes (works on both web and mobile)
      final imageBytes = await image.readAsBytes();

      final downloadUrl = await vm.uploadQuizCover(imageBytes, userId);

      if (mounted && downloadUrl != null) {
        setState(() {
          _selectedCover = downloadUrl;
          _isUploading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tải ảnh lên thành công! ✅'),
              backgroundColor: AppColors.tertiaryContainer,
            ),
          );
        }
      } else if (mounted) {
        setState(() => _isUploading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authVm = context.read<AuthViewModel>();
    final userEmail = authVm.currentUser?.email;
    final isAdmin = userEmail != null && userEmail.trim().toLowerCase() == 'll.stylish73@gmail.com';

    final vm = context.read<QuizManagerViewModel>();
    vm.updateQuizDetails(
      title: _titleController.text,
      description: _descController.text,
      imageUrl: _selectedCover,
      isPublic: isAdmin ? _isPublic : false,
    );

    final success = await vm.saveQuiz();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu bộ câu hỏi thành công! 🎉'),
          backgroundColor: AppColors.tertiaryContainer,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QuizManagerViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Tạo Bộ Câu Hỏi',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Section 1: Details
                            Text(
                              'THÔNG TIN CHI TIẾT',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: AppColors.outlineVariant),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _titleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Tên bộ câu hỏi / Chủ đề',
                                        hintText: 'Ví dụ: Ẩm thực miền Tây, Di tích Hà Nội...',
                                        prefixIcon: Icon(Icons.title, color: AppColors.primary),
                                        border: InputBorder.none,
                                      ),
                                      validator: (val) =>
                                          val == null || val.trim().isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                                    ),
                                    const Divider(),
                                    TextFormField(
                                      controller: _descController,
                                      maxLines: 2,
                                      decoration: const InputDecoration(
                                        labelText: 'Mô tả bộ câu hỏi',
                                        hintText: 'Nhập mô tả ngắn giúp người chơi hiểu về chủ đề này...',
                                        prefixIcon: Icon(Icons.description_outlined, color: AppColors.primary),
                                        border: InputBorder.none,
                                      ),
                                      validator: (val) =>
                                          val == null || val.trim().isEmpty ? 'Vui lòng nhập mô tả' : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Section 2: Cover Image Selection
                            Text(
                              'CHỌN ẢNH BÌA BỘ CÂU HỎI',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _selectedCover.isEmpty
                                ? GestureDetector(
                                    onTap: _isUploading ? null : _pickAndUploadImage,
                                    child: Container(
                                      height: 110,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.04),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.25),
                                          width: 1.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: _isUploading
                                          ? const Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.primary,
                                              ),
                                            )
                                          : const Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.cloud_upload_outlined,
                                                  color: AppColors.primary,
                                                  size: 34,
                                                ),
                                                SizedBox(height: 6),
                                                Text(
                                                  'Tải ảnh bìa từ thiết bị lên',
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  )
                                : Container(
                                    height: 140,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: DecorationImage(
                                        image: NetworkImage(_selectedCover),
                                        fit: BoxFit.cover,
                                      ),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _selectedCover = '';
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          left: 8,
                                          child: ElevatedButton.icon(
                                            onPressed: _isUploading
                                                ? null
                                                : _pickAndUploadImage,
                                            icon: const Icon(
                                              Icons.photo_library_outlined,
                                              size: 16,
                                            ),
                                            label: const Text(
                                              'Thay đổi ảnh bìa',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.white.withValues(alpha: 0.9),
                                              foregroundColor: AppColors.primary,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            const SizedBox(height: 32),

                            // Section 4: Questions List Header
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'CÂU HỎI (${vm.editingQuestions.length})',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.primary,
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: vm.addQuestion,
                                  icon: const Icon(Icons.add_circle_outline, size: 16),
                                  label: const Text('Thêm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Performance Optimized Question Cards
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: vm.editingQuestions.length,
                              itemBuilder: (context, qIdx) {
                                final question = vm.editingQuestions[qIdx];
                                return _QuestionCard(
                                  key: ValueKey(question.id),
                                  question: question,
                                  index: qIdx,
                                  canDelete: vm.editingQuestions.length > 1,
                                  onDelete: () => vm.removeQuestion(qIdx),
                                  onCorrectIndexChanged: (correctIdx) =>
                                      vm.updateQuestionCorrectIndex(qIdx, correctIdx),
                                  onTimeLimitChanged: (timeLimit) =>
                                      vm.updateQuestionTimeLimit(qIdx, timeLimit),
                                  onQuestionTextUpdated: (text) =>
                                      vm.updateQuestionText(qIdx, text),
                                  onOptionUpdated: (optIdx, val) =>
                                      vm.updateQuestionOption(qIdx, optIdx, val),
                                  onHintUpdated: (hint) =>
                                      vm.updateQuestionHint(qIdx, hint),
                                );
                              },
                            ),
                            
                            // Error message
                            if (vm.errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                vm.errorMessage!,
                                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Action Bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _onSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Lưu Bộ Câu Hỏi',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Isolated StatefulWidget for each Question Card to eliminate frame drops and keyboard lag.
class _QuestionCard extends StatefulWidget {
  final QuizQuestion question;
  final int index;
  final bool canDelete;
  final VoidCallback onDelete;
  final ValueChanged<int> onCorrectIndexChanged;
  final ValueChanged<int> onTimeLimitChanged;
  final ValueChanged<String> onQuestionTextUpdated;
  final Function(int optIndex, String text) onOptionUpdated;
  final ValueChanged<String> onHintUpdated;

  const _QuestionCard({
    super.key,
    required this.question,
    required this.index,
    required this.canDelete,
    required this.onDelete,
    required this.onCorrectIndexChanged,
    required this.onTimeLimitChanged,
    required this.onQuestionTextUpdated,
    required this.onOptionUpdated,
    required this.onHintUpdated,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late final TextEditingController _textController;
  late final TextEditingController _hintController;
  late final List<TextEditingController> _optionControllers;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.question.text);
    _hintController = TextEditingController(text: widget.question.hintText ?? '');
    _optionControllers = List.generate(
      4,
      (i) => TextEditingController(
        text: i < widget.question.options.length ? widget.question.options[i] : '',
      ),
    );

    _textController.addListener(() {
      widget.onQuestionTextUpdated(_textController.text);
    });

    _hintController.addListener(() {
      widget.onHintUpdated(_hintController.text);
    });

    for (int i = 0; i < 4; i++) {
      final index = i;
      _optionControllers[i].addListener(() {
        widget.onOptionUpdated(index, _optionControllers[index].text);
      });
    }
  }

  @override
  void didUpdateWidget(covariant _QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _textController.text = widget.question.text;
      _hintController.text = widget.question.hintText ?? '';
      for (int i = 0; i < 4; i++) {
        if (i < widget.question.options.length) {
          _optionControllers[i].text = widget.question.options[i];
        }
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _hintController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'CÂU HỎI ${widget.index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (widget.canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: widget.onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Question text input
            TextFormField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Nội dung câu hỏi',
                hintText: 'Nhập câu hỏi của bạn...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Nội dung câu hỏi không được để trống' : null,
            ),
            const SizedBox(height: 16),

            // Time limit and Hint row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: widget.question.timeLimit,
                    decoration: InputDecoration(
                      labelText: 'Thời gian trả lời',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 10, child: Text('10 giây')),
                      DropdownMenuItem(value: 20, child: Text('20 giây')),
                      DropdownMenuItem(value: 30, child: Text('30 giây')),
                      DropdownMenuItem(value: 60, child: Text('60 giây')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        widget.onTimeLimitChanged(val);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _hintController,
                    decoration: InputDecoration(
                      labelText: 'Gợi ý (Không bắt buộc)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Options A, B, C, D
            const Text(
              'CÁC ĐÁP ÁN LỰA CHỌN (Tích xanh chọn đáp án đúng)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: AppColors.outline,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            ...List.generate(4, (oIdx) {
              final isCorrect = widget.question.correctIndex == oIdx;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    // Correct index selector check icon
                    IconButton(
                      icon: Icon(
                        isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isCorrect ? Colors.green : AppColors.outline,
                      ),
                      onPressed: () => widget.onCorrectIndexChanged(oIdx),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextFormField(
                        controller: _optionControllers[oIdx],
                        decoration: InputDecoration(
                          hintText: 'Đáp án ${String.fromCharCode(65 + oIdx)}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Đáp án không được để trống' : null,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
