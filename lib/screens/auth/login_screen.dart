import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final res = await AuthService.login(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      final role = res['user']['role'];
      Navigator.pushReplacementNamed(context, role == 'doctor' ? '/doctor' : '/patient');
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AuthBackground(),
          AuthCard(
            form: _LoginForm(
              formKey: _formKey,
              emailCtrl: _emailCtrl,
              passCtrl: _passCtrl,
              obscure: _obscure,
              loading: _loading,
              error: _error,
              onToggleObscure: () => setState(() => _obscure = !_obscure),
              onSubmit: _login,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.loading,
    required this.error,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final bool loading;
  final String? error;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome back', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kAuthNavy)),
          const SizedBox(height: 6),
          Text('Sign in to continue to your dashboard', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 28),
          AuthErrorBanner(error: error),
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: authFieldDecoration(label: 'Email Address', icon: Icons.email_outlined),
            validator: (v) => v!.isEmpty ? 'Enter your email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passCtrl,
            obscureText: obscure,
            decoration: authFieldDecoration(
              label: 'Password',
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                onPressed: onToggleObscure,
              ),
            ),
            validator: (v) => v!.isEmpty ? 'Enter your password' : null,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 26),
          AuthPrimaryButton(label: 'LOG IN', loading: loading, onTap: onSubmit),
          const SizedBox(height: 18),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: TextButton.styleFrom(foregroundColor: kAuthBlue),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 13.5, color: Colors.grey[700]),
                  children: const [
                    TextSpan(text: "Don't have an account? "),
                    TextSpan(text: 'Register', style: TextStyle(color: kAuthBlue, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
