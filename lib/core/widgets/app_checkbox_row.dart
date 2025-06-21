import 'package:flutter/material.dart';
import 'package:task_app/core/widgets/app_text.dart';

class AppCheckboxRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String text;

  const AppCheckboxRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            value
                ? 'assets/images/checkbox_checked.png'
                : 'assets/images/checkbox_unchecked.png',
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 8),
          const SizedBox(height: 24),
          AppText(
            text: text,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            lineHeight: 20 / 13,
            letterSpacing: -0.24,
            color: Color(0xFF101840),
          ),
        ],
      ),
    );
  }
}
