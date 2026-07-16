import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'patient';
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final res = await AuthService.register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text, _role);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, res['user']['role'] == 'doctor' ? '/doctor' : '/patient');
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
            form: _RegisterForm(
              formKey: _formKey,
              nameCtrl: _nameCtrl,
              emailCtrl: _emailCtrl,
              passCtrl: _passCtrl,
              role: _role,
              obscure: _obscure,
              loading: _loading,
              error: _error,
              onRoleChanged: (r) => setState(() => _role = r),
              onToggleObscure: () => setState(() => _obscure = !_obscure),
              onSubmit: _register,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.role,
    required this.obscure,
    required this.loading,
    required this.error,
    required this.onRoleChanged,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final String role;
  final bool obscure;
  final bool loading;
  final String? error;
  final ValueChanged<String> onRoleChanged;
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
          const Text('Create account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kAuthNavy)),
          const SizedBox(height: 6),
          Text('Join OmniCare to start your care journey', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 28),
          AuthErrorBanner(error: error),
          TextFormField(
            controller: nameCtrl,
            decoration: authFieldDecoration(label: 'Full Name', icon: Icons.person_outline),
            validator: (v) => v!.isEmpty ? 'Enter your full name' : null,
          ),
          const SizedBox(height: 16),
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
            validator: (v) => v!.length < 8 ? 'Min 8 characters' : null,
          ),
          const SizedBox(height: 20),
          Text('I am a', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[700])),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _RoleCard(label: 'Patient', icon: Icons.personal_injury_rounded, selected: role == 'patient', onTap: () => onRoleChanged('patient'))),
              const SizedBox(width: 12),
              Expanded(child: _RoleCard(label: 'Doctor', icon: Icons.medical_services_rounded, selected: role == 'doctor', onTap: () => onRoleChanged('doctor'))),
            ],
          ),
          const SizedBox(height: 26),
          AuthPrimaryButton(label: 'CREATE ACCOUNT', loading: loading, onTap: onSubmit),
          const SizedBox(height: 18),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: kAuthBlue),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 13.5, color: Colors.grey[700]),
                  children: const [
                    TextSpan(text: 'Already have an account? '),
                    TextSpan(text: 'Sign In', style: TextStyle(color: kAuthBlue, fontWeight: FontWeight.w700)),
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? kAuthNavy.withValues(alpha: 0.06) : const Color(0xFFF6F8FB),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? kAuthBlue : const Color(0xFFE1E7EF), width: selected ? 1.6 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? kAuthNavy : Colors.grey[500], size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: selected ? kAuthNavy : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
