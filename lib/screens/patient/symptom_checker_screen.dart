import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'diagnosis_result_screen.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});
  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  List<dynamic> _symptoms = [];
  final Set<int> _selected = {};
  bool _loading = true;
  bool _checking = false;

  @override
  void initState() { super.initState(); _loadSymptoms(); }

  Future<void> _loadSymptoms() async {
    try {
      final res = await ApiService.get('symptoms');
      setState(() { _symptoms = res['data']; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  Future<void> _check() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one symptom')));
      return;
    }
    setState(() => _checking = true);
    try {
      final res = await ApiService.post('symptom-checker', {'symptom_ids': _selected.toList()});
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => DiagnosisResultScreen(results: List<Map<String, dynamic>>.from(res['results'])),
      ));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Symptom Checker')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF1F4E79).withValues(alpha: 0.08),
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: Color(0xFF1F4E79)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      '${_selected.length} symptom(s) selected. Tap to select all that apply.',
                      style: const TextStyle(fontSize: 13),
                    )),
                  ]),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _symptoms.length,
                    itemBuilder: (_, i) {
                      final s = _symptoms[i];
                      final id = s['id'] as int;
                      final selected = _selected.contains(id);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: selected ? const Color(0xFF1F4E79).withValues(alpha: 0.08) : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: selected ? const Color(0xFF1F4E79) : Colors.grey[200]!, width: selected ? 1.5 : 1),
                        ),
                        child: CheckboxListTile(
                          value: selected,
                          activeColor: const Color(0xFF1F4E79),
                          onChanged: (_) => setState(() => selected ? _selected.remove(id) : _selected.add(id)),
                          title: Text(s['name'], style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                          subtitle: s['description'] != null ? Text(s['description'], style: const TextStyle(fontSize: 12)) : null,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _checking ? null : _check,
                      icon: _checking ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.search),
                      label: Text(_checking ? 'Analysing...' : 'CHECK SYMPTOMS (${_selected.length} selected)'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
