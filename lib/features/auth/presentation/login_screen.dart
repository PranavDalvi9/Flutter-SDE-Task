import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                'Login or Sign up to continue',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 24),
              TextField(
                controller: _email,
                decoration: InputDecoration(
                  hintText: 'Enter your username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(unselectedWidgetColor: Color(0xFF371382)),
                    child: Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        shape: CircleBorder(),
                        activeColor: Color(0xFF371382),
                        value: _hasReferral,
                        onChanged: (value) {
                          setState(() {
                            _hasReferral = value ?? false;
                          });
                        },
                      ),
                    ),
                  ),
                  Text(
                    'I have a referral code (optional)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Spacer(),
              RichText(
                text: TextSpan(
                  text: 'By clicking, I accept the ',
                  style: TextStyle(color: const Color(0xFF525871)),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Terms of Use',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                    TextSpan(text: ' & '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isFormValid
                          ? () {
                            _login();
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isFormValid ? Color(0xFF371382) : Colors.grey[300],
                    foregroundColor:
                        _isFormValid ? Colors.white : Colors.black38,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
