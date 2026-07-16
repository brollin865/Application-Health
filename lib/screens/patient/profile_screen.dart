import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/dashboard_widgets.dart';

const _kNavy = Color(0xFF1F4E79);
const _kBlue = Color(0xFF2E75B6);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _ageCtrl     = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emergCtrl   = TextEditingController();
  final _histCtrl    = TextEditingController();
  String _gender = 'Male';
  bool _loading = true;
  bool _saving = false;
  int? _patientId;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiService.get('patients');
      final data = res['data'];
      if (data != null && data is List && data.isNotEmpty) {
        final p = data[0];
        _patientId = p['id'];
        _nameCtrl.text    = p['full_name'] ?? '';
        _ageCtrl.text     = p['age']?.toString() ?? '';
        _phoneCtrl.text   = p['phone'] ?? '';
        _addressCtrl.text = p['address'] ?? '';
        _emergCtrl.text   = p['emergency_contact'] ?? '';
        _histCtrl.text    = p['medical_history'] ?? '';
        _gender           = p['gender'] ?? 'Male';
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final body = {
        'full_name': _nameCtrl.text, 'age': int.tryParse(_ageCtrl.text) ?? 0,
        'gender': _gender, 'phone': _phoneCtrl.text, 'address': _addressCtrl.text,
        'emergency_contact': _emergCtrl.text, 'medical_history': _histCtrl.text,
      };
      if (_patientId != null) {
        await ApiService.put('patients/$_patientId', body);
      } else {
        await ApiService.post('patients', body);
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved!'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _decoration({required String label, required IconData icon, bool alignTop = false}) {
    OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      alignLabelWithHint: alignTop,
      filled: true,
      fillColor: const Color(0xFFF6F8FB),
      border: border(const Color(0xFFE1E7EF), 1),
      enabledBorder: border(const Color(0xFFE1E7EF), 1),
      focusedBorder: border(_kBlue, 1.6),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : null;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(title: const Text('My Profile'), actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: () async {
          await AuthService.logout();
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/login');
        }),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kNavy))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  FadeSlideIn(
                    child: Center(
                      child: Container(
                        width: 88, height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [_kNavy, _kBlue]),
                          boxShadow: [BoxShadow(color: _kNavy.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                        ),
                        alignment: Alignment.center,
                        child: initial != null
                            ? Text(initial, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold))
                            : const Icon(Icons.person_rounded, size: 42, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: _section(
                      title: 'Personal Information',
                      icon: Icons.badge_outlined,
                      children: [
                        TextFormField(controller: _nameCtrl, decoration: _decoration(label: 'Full Name', icon: Icons.person_outline), validator: (v) => v!.isEmpty ? 'Required' : null),
                        const SizedBox(height: 14),
                        Row(children: [
                          Expanded(child: TextFormField(controller: _ageCtrl, keyboardType: TextInputType.number, decoration: _decoration(label: 'Age', icon: Icons.cake_outlined))),
                          const SizedBox(width: 12),
                          Expanded(child: DropdownButtonFormField<String>(
                            initialValue: _gender,
                            decoration: _decoration(label: 'Gender', icon: Icons.wc_outlined),
                            items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (v) => setState(() => _gender = v!),
                          )),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    child: _section(
                      title: 'Contact Information',
                      icon: Icons.contact_phone_outlined,
                      children: [
                        TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: _decoration(label: 'Phone Number', icon: Icons.phone_outlined)),
                        const SizedBox(height: 14),
                        TextFormField(controller: _addressCtrl, maxLines: 2, decoration: _decoration(label: 'Residential Address', icon: Icons.location_on_outlined)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 180),
                    child: _section(
                      title: 'Medical Information',
                      icon: Icons.medical_information_outlined,
                      children: [
                        TextFormField(controller: _emergCtrl, decoration: _decoration(label: 'Emergency Contact', icon: Icons.emergency_outlined)),
                        const SizedBox(height: 14),
                        TextFormField(controller: _histCtrl, maxLines: 3, decoration: _decoration(label: 'Medical History', icon: Icons.history_rounded, alignTop: true)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 240),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: _saving ? null : const LinearGradient(colors: [_kNavy, _kBlue]),
                          color: _saving ? Colors.grey[300] : null,
                          boxShadow: _saving ? null : [BoxShadow(color: _kNavy.withValues(alpha: 0.32), blurRadius: 16, offset: const Offset(0, 8))],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _saving ? null : _save,
                            child: Center(
                              child: _saving
                                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: _kNavy, strokeWidth: 2.4))
                                  : const Text('SAVE PROFILE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.6)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
    );
  }

  Widget _section({required String title, required IconData icon, required List<Widget> children}) {
    return DashboardCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, icon: icon),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
