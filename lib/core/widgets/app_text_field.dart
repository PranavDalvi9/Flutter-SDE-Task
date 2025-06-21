import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final bool isEnabled;

  const AppTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.isEnabled = true,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFD9DBE9), width: 1),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF371382), width: 1.2),
    );

    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      enabled: widget.isEnabled,
      style: const TextStyle(
        fontFamily: 'SFProDisplay',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.33, // 20/15
        letterSpacing: -0.24,
        color: Color(0xFF101840),
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          fontFamily: 'SFProDisplay',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: -0.24,
          color: Color(0xFFC1C4D6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: baseBorder,
        focusedBorder: focusedBorder,
        border: baseBorder,
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  onPressed: () {
                    setState(() => _obscureText = !_obscureText);
                  },
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: const Color(0xFF101840),
                  ),
                )
                : null,
      ),
    );
  }
}
