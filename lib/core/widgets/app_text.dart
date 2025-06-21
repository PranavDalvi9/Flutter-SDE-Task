import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double lineHeight;
  final double letterSpacing;
  final Color color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.lineHeight = 1.2,
    this.letterSpacing = 0.0,
    this.color = const Color(0xFF000000),
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: 'SFProDisplay',
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: lineHeight,
        letterSpacing: letterSpacing,
        color: color,
      ),
    );
  }
}
