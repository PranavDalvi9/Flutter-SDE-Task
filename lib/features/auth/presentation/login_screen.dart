import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_app/core/widgets/app_checkbox_row.dart';
import 'package:task_app/core/widgets/app_text.dart';
import 'package:task_app/core/widgets/app_text_field.dart';
import '../../questionnaire/presentation/questionnaire_screen.dart';
import '../services/auth_service.dart';
import '../../../core/services/local_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _hasReferral = false;

  final AuthService _authService = AuthService();

  bool isLoading = false;

  bool _isFormValid = false;

  Future<void> _login() async {
    setState(() => isLoading = true);
    try {
      User? user = await _authService.signIn(
        _email.text.trim(),
        _password.text.trim(),
      );
      if (user != null) {
        await LocalStorage.saveCurrentScreen('questionnaire');
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuestionnaireScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    _email.addListener(_validateForm);
    _password.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = _email.text.isNotEmpty && _password.text.isNotEmpty;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 74),
              AppText(
                text: 'Login or Sign up to continue',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                lineHeight: 22 / 17, // ~1.29
                letterSpacing: -0.24,
                color: Color(0xFF101840),
              ),
              SizedBox(height: 24),

              AppTextField(hintText: 'Enter your username', controller: _email),

              SizedBox(height: 16),

              AppTextField(
                hintText: 'Enter password',
                controller: _password,
                isPassword: true,
              ),

              SizedBox(height: 32),

              AppCheckboxRow(
                value: _hasReferral,
                onChanged: (val) => setState(() => _hasReferral = val),
                text: 'I have a referral code (optional)',
              ),

              Spacer(),

              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: 'By clicking, I accept the ',

                    style: TextStyle(
                      fontFamily: 'SFProDisplay',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 18 / 13,
                      letterSpacing: -0.24,
                      color: Color(0xFF525871),
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms of Use',
                        style: TextStyle(
                          fontFamily: 'SFProDisplay',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 18 / 13,
                          letterSpacing: -0.24,
                          color: Color(0xFF525871),
                          decoration: TextDecoration.underline,
                          decorationThickness: 1,
                          decorationStyle: TextDecorationStyle.solid,
                        ),
                      ),
                      TextSpan(text: ' & '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          fontFamily: 'SFProDisplay',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 18 / 13,
                          letterSpacing: -0.24,
                          color: Color(0xFF525871),
                          decoration: TextDecoration.underline,
                          decorationThickness: 1,
                          decorationStyle: TextDecorationStyle.solid,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isFormValid ? _login : null,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) =>
                          states.contains(MaterialState.disabled)
                              ? const Color(0xFFE4E4EC)
                              : const Color(0xFF371382),
                    ),
                    foregroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) =>
                          states.contains(MaterialState.disabled)
                              ? const Color(0xFFA0A3BD)
                              : Colors.white,
                    ),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      const TextStyle(
                        fontFamily: 'SFProDisplay',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 20 / 15, // ~1.33
                        letterSpacing: -0.24,
                      ),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
