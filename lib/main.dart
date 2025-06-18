import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:task_app/core/services/local_storage.dart';
import 'package:task_app/features/auth/presentation/login_screen.dart';
import 'package:task_app/features/break_timer/presentation/break_screen.dart';
import 'package:task_app/features/questionnaire/presentation/questionnaire_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final lastScreen = await LocalStorage.getCurrentScreen();
  runApp(MyApp(initialScreen: lastScreen));
}

class MyApp extends StatelessWidget {
  final String? initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    Widget startScreen;
    if (FirebaseAuth.instance.currentUser == null) {
      startScreen = const LoginScreen();
    } else if (initialScreen == 'questionnaire') {
      startScreen = const QuestionnaireScreen();
    } else if (initialScreen == 'homescreen') {
      startScreen = BreakScreen();
    } else {
      startScreen = const LoginScreen();
    }

    return MaterialApp(debugShowCheckedModeBanner: false, home: startScreen);
  }
}
