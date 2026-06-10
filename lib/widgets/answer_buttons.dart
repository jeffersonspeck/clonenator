// lib/widgets/answer_buttons.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';

class AnswerButtons extends StatelessWidget {
  final void Function(UserAnswer) onAnswer;

  const AnswerButtons({super.key, required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _AnswerButton(
              answer: UserAnswer.yes,
              onTap: onAnswer,
              icon: Icons.check_circle_rounded,
              flex: 1,
            ),
            const SizedBox(width: 8),
            _AnswerButton(
              answer: UserAnswer.no,
              onTap: onAnswer,
              icon: Icons.cancel_rounded,
              flex: 1,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _AnswerButton(
              answer: UserAnswer.probablyYes,
              onTap: onAnswer,
              icon: Icons.thumb_up_alt_outlined,
              flex: 1,
            ),
            const SizedBox(width: 8),
            _AnswerButton(
              answer: UserAnswer.probablyNo,
              onTap: onAnswer,
              icon: Icons.thumb_down_alt_outlined,
              flex: 1,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _AnswerButton(
          answer: UserAnswer.unknown,
          onTap: onAnswer,
          icon: Icons.help_outline_rounded,
          flex: 1,
          fullWidth: true,
        ),
      ],
    );
  }
}

class _AnswerButton extends StatefulWidget {
  final UserAnswer answer;
  final void Function(UserAnswer) onTap;
  final IconData icon;
  final int flex;
  final bool fullWidth;

  const _AnswerButton({
    required this.answer,
    required this.onTap,
    required this.icon,
    required this.flex,
    this.fullWidth = false,
  });

  @override
  State<_AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<_AnswerButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.answerColor(widget.answer);
    final label = AppTheme.answerLabel(widget.answer);

    Widget button = GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap(widget.answer);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: color, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return Expanded(child: button);
  }
}
