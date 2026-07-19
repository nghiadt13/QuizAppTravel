import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PinInputField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onComplete;
  final int pinLength;

  const PinInputField({
    super.key,
    required this.onChanged,
    this.onComplete,
    this.pinLength = 6,
  });

  @override
  State<PinInputField> createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<PinInputField>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    widget.onChanged(text);
    if (text.length == widget.pinLength && widget.onComplete != null) {
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
                maxLength: widget.pinLength,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.pinLength, (index) {
              final text = _controller.text;
              final isFocused = _focusNode.hasFocus && text.length == index;
              final hasCharacter = text.length > index;
              final character = hasCharacter ? text[index] : '';

              // Add spacing in the middle for 6-digit PIN (3 + 3)
              final spacing = (index == 3) ? 16.0 : 6.0;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (index > 0) SizedBox(width: spacing),
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final glowOpacity = isFocused
                          ? _pulseAnimation.value * 0.4
                          : 0.0;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: hasCharacter
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isFocused
                                ? AppColors.secondaryContainer
                                : hasCharacter
                                    ? AppColors.primary
                                    : AppColors.outlineVariant,
                            width: isFocused ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            if (isFocused)
                              BoxShadow(
                                color: AppColors.secondaryContainer
                                    .withValues(alpha: glowOpacity),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            if (hasCharacter)
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: hasCharacter
                            ? Text(
                                character,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              )
                            : AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, _) {
                                  final dotOpacity = isFocused
                                      ? 0.3 + (_pulseAnimation.value * 0.4)
                                      : 0.2;
                                  return Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.outline
                                          .withValues(alpha: dotOpacity),
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                },
                              ),
                      );
                    },
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
