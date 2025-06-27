import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_app/core/widgets/app_text.dart';
import 'package:task_app/features/break_timer/presentation/circular_timer.dart';

class BreakActiveCard extends StatelessWidget {
  final Duration remaining;
  final DateTime breakEndTime;
  final Duration duration;
  final VoidCallback onEndNow;

  const BreakActiveCard({
    super.key,
    required this.remaining,
    required this.breakEndTime,
    required this.duration,
    required this.onEndNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/card_background.png'),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          const AppText(
            text: 'We value your hard work!\nTake this time to relax',
            textAlign: TextAlign.center,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            lineHeight: 1.3,
            color: Colors.white,
          ),
          const SizedBox(height: 30),
          CircularTimer(remaining: remaining, total: duration, label: "Break"),
          const SizedBox(height: 38),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 36),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFACC4E8CC)),
                bottom: BorderSide(color: Color(0xFFACC4E8CC)),
              ),
            ),
            child: AppText(
              text:
                  "Break ends at ${DateFormat('hh:mm a').format(breakEndTime)}",
              textAlign: TextAlign.center,
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              lineHeight: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onEndNow,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 36),
              decoration: BoxDecoration(
                color: const Color(0xFFD14343),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14.5),
              child: const AppText(
                text: 'End my break',
                textAlign: TextAlign.center,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                lineHeight: 1.38,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
