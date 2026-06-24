import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: () async {
          await AuthService.logout();
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/login');
        }),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  const CircleAvatar(radius: 40, backgroundColor: Color(0xFF1F4E79), child: Icon(Icons.person, size: 44, color: Colors.white)),
                  const SizedBox(height: 20),
                  TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: TextFormField(controller: _ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.cake)))),
                    const SizedBox(width: 12),
                    Expanded(child: DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.wc)),
                      items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                    )),
                  ]),
                  const SizedBox(height: 12),
                  TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone))),
                  const SizedBox(height: 12),
                  TextFormField(controller: _addressCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Residential Address', prefixIcon: Icon(Icons.location_on))),
                  const SizedBox(height: 12),
                  TextFormField(controller: _emergCtrl, decoration: const InputDecoration(labelText: 'Emergency Contact', prefixIcon: Icon(Icons.emergency))),
                  const SizedBox(height: 12),
                  TextFormField(controller: _histCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Medical History', prefixIcon: Icon(Icons.history), alignLabelWithHint: true)),
                  const SizedBox(height: 24),
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('SAVE PROFILE'),
                  )),
                ]),
              ),
            ),
    );
  }
}
