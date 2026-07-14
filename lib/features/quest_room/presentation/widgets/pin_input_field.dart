import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PinInputField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onComplete;

  const PinInputField({
    super.key,
    required this.onChanged,
    this.onComplete,
  });

  @override
  State<PinInputField> createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<PinInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    widget.onChanged(text);
    if (text.length == 6 && widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hidden TextField
          Opacity(
            opacity: 0,
            child: SizedBox(
              width: 0,
              height: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                autofocus: true,
                decoration: const InputDecoration(
                  counterText: '',
                ),
              ),
            ),
          ),
          // Stylized Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              final text = _controller.text;
              final isFocused = _focusNode.hasFocus && text.length == index;
              final hasCharacter = text.length > index;
              final character = hasCharacter ? text[index] : '';

              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 48,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFocused
                        ? AppColors.secondaryContainer // Sunny Yellow Accent
                        : (hasCharacter ? AppColors.primary : AppColors.outlineVariant),
                    width: isFocused ? 2.5 : 1.5,
                  ),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  character,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
