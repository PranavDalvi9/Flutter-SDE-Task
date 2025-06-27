import 'package:flutter/material.dart';
import 'package:task_app/core/widgets/app_text.dart';

class BreakEndedCard extends StatelessWidget {
  const BreakEndedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 307,
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage('assets/images/timer_end_background.png'),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 64),
          Image.asset('assets/images/tick_icon.png', height: 123),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: AppText(
              text:
                  "Hope you are feeling refreshed and \nready to start working again",
              textAlign: TextAlign.center,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              lineHeight: 1.3,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 52),
        ],
      ),
    );
  }
}
