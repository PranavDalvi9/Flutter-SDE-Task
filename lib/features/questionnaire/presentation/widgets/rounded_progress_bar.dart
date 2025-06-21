import 'package:flutter/material.dart';

class RoundedProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color backgroundColor;
  final Color fillColor;

  const RoundedProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.backgroundColor = const Color(0xFFDBDAE5),
    this.fillColor = const Color(0xFF3030D6),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final filledWidth = width * progress.clamp(0.0, 1.0);

          return Stack(
            children: [
              Container(width: width, height: height, color: backgroundColor),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: filledWidth,
                height: height,
                color: fillColor,
              ),
            ],
          );
        },
      ),
    );
  }
}
