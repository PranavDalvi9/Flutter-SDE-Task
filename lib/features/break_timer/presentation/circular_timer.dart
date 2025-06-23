import 'package:flutter/material.dart';
import 'dart:math';

import 'package:task_app/core/widgets/app_text.dart';

class CircularTimer extends StatelessWidget {
  final Duration remaining;
  final Duration total;
  final String label;

  const CircularTimer({
    required this.remaining,
    required this.total,
    this.label = "Break",
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (1 - remaining.inSeconds / total.inSeconds).clamp(0.0, 1.0);
    final formattedTime =
        "${remaining.inMinutes.toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}";

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: _TimerPainter(percent),
            child: Center(
              child: Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 1,
          right: 0,
          left: 0,
          child: AppText(
            text: label,
            textAlign: TextAlign.center,
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double percent;

  _TimerPainter(this.percent);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 20.0;
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final sweepAngle = 5 * pi / 2.92;
    final startAngle = 90.0;

    final progressAngle = sweepAngle * percent;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background arc
    final backgroundPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);

    // Progress arc with flat start
    final progressPaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, startAngle, progressAngle, false, progressPaint);

    // Draw rounded cap manually at the end
    if (percent > 0) {
      final endX = center.dx + radius * cos(startAngle + progressAngle);
      final endY = center.dy + radius * sin(startAngle + progressAngle);
      final capPaint = Paint()..color = Colors.white;

      canvas.drawCircle(Offset(endX, endY), strokeWidth / 2, capPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) {
    return oldDelegate.percent != percent;
  }
}
