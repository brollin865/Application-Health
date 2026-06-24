import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  String _role = 'patient';
  bool _loading = false;
  bool _obscure = true;
  String? _error;

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
      backgroundColor: const Color(0xFFEEF2F7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Create Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F4E79))),
                    const SizedBox(height: 4),
                    const Text('Health Monitoring & Diagnosis System', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 24),
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red[200]!)),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),
                    TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 14),
                    TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)), validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passCtrl, obscureText: _obscure,
                      decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure))),
                      validator: (v) => v!.length < 8 ? 'Min 8 characters' : null,
                    ),
                    const SizedBox(height: 18),
                    const Align(alignment: Alignment.centerLeft, child: Text('Select Role', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F4E79)))),
                    const SizedBox(height: 8),
                    Row(
                      children: ['patient', 'doctor'].map((r) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(r[0].toUpperCase() + r.substring(1)),
                            selected: _role == r,
                            onSelected: (_) => setState(() => _role = r),
                            selectedColor: const Color(0xFF1F4E79),
                            labelStyle: TextStyle(color: _role == r ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        child: _loading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 16, letterSpacing: 1)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Already have an account? Sign In')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
