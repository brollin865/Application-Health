import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DoctorConsultationScreen extends StatefulWidget {
  const DoctorConsultationScreen({super.key});
  @override
  State<DoctorConsultationScreen> createState() => _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState extends State<DoctorConsultationScreen> {
  List<dynamic> _consultations = [];
  List<dynamic> _diagnoses = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final cRes = await ApiService.get('consultations');
      final dRes = await ApiService.get('diagnoses');
      setState(() {
        _consultations = cRes['data'];
        _diagnoses = dRes['data'];
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  void _openReview(Map consultation) {
    int? selectedDiagId;
    final recCtrl = TextEditingController(text: consultation['recommendation'] ?? '');
    String status = consultation['status'] ?? 'pending';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 20),
        child: StatefulBuilder(builder: (ctx, setS) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Review Consultation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Patient: ${consultation['patient']?['user']?['name'] ?? 'Unknown'}', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Severity: ${consultation['severity'] ?? '—'}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Notes: ${consultation['notes'] ?? '—'}'),
            ]),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Assign Formal Diagnosis', border: OutlineInputBorder()),
            items: _diagnoses.map<DropdownMenuItem<int>>((d) => DropdownMenuItem(value: d['id'] as int, child: Text(d['disease_name']))).toList(),
            onChanged: (v) => setS(() => selectedDiagId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: recCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Clinical Recommendation', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(children: ['pending','under_review','completed'].map((s) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(s.replaceAll('_', ' '), style: const TextStyle(fontSize: 11)),
                selected: status == s,
                onSelected: (_) => setS(() => status = s),
                selectedColor: const Color(0xFF1F4E79),
                labelStyle: TextStyle(color: status == s ? Colors.white : Colors.black87),
              ),
            ),
          )).toList()),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final diagName = _diagnoses.firstWhere((d) => d['id'] == selectedDiagId, orElse: () => {})['disease_name'];
                  await ApiService.put('consultations/${consultation['id']}', {
                    'diagnosis_id': selectedDiagId,
                    'diagnosis_name': diagName ?? '',
                    'recommendation': recCtrl.text,
                    'status': status,
                  });
                  if (!mounted) return;
                  Navigator.pop(context);
                  _load();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Consultation updated!'), backgroundColor: Colors.green));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                }
              },
              child: const Text('SAVE & UPDATE'),
            ),
          ),
          const SizedBox(height: 20),
        ])),
      ),
    );
  }

  Color _statusColor(String s) => switch (s) {
    'pending'      => Colors.orange,
    'under_review' => Colors.blue,
    'completed'    => Colors.green,
    _              => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Consultations')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _consultations.isEmpty
                  ? const Center(child: Text('No consultations found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _consultations.length,
                      itemBuilder: (_, i) {
                        final c = _consultations[i];
                        final status = c['status'] ?? 'pending';
                        final col = _statusColor(status);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: col.withValues(alpha: 0.5))),
                          child: ListTile(
                            leading: CircleAvatar(backgroundColor: col.withValues(alpha: 0.15), child: Icon(Icons.person, color: col)),
                            title: Text(c['patient']?['user']?['name'] ?? 'Patient', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${c['severity'] ?? 'Unknown severity'}  •  ${c['created_at']?.toString().split('T')[0] ?? ''}'),
                            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(8)),
                                child: Text(status.toUpperCase().replaceAll('_',' '), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 4),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            ]),
                            onTap: () => _openReview(Map<String, dynamic>.from(c)),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
