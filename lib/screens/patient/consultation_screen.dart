import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'consultation_detail_screen.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});
  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  List<dynamic> _consultations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.get('consultations');
      setState(() {
        _consultations = res['data'];
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Color _statusColor(String s) => switch (s) {
        'pending' => Colors.orange,
        'under_review' => Colors.blue,
        'completed' => Colors.green,
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Consultations')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _consultations.isEmpty
              ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      const Icon(Icons.list_alt, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No consultations yet'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/symptom-checker'),
                          child: const Text('Start Symptom Check')),
                    ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _consultations.length,
                    itemBuilder: (_, i) {
                      final c = _consultations[i];
                      final status = c['status'] ?? 'pending';
                      final col = _statusColor(status);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side:
                                BorderSide(color: col.withValues(alpha: 0.4))),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConsultationDetailScreen(
                                    consultation: Map<String, dynamic>.from(c)),
                              )),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: col,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Text(
                                            status
                                                .toUpperCase()
                                                .replaceAll('_', ' '),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold))),
                                    const Spacer(),
                                    Text(c['severity'] ?? '',
                                        style: TextStyle(
                                            color: col,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                  ]),
                                  const SizedBox(height: 8),
                                  Text('Notes: ${c['notes'] ?? 'No notes'}',
                                      style: const TextStyle(fontSize: 13)),
                                  if (c['recommendation'] != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.green[50],
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Row(children: [
                                        const Icon(Icons.medical_services,
                                            size: 16, color: Colors.green),
                                        const SizedBox(width: 6),
                                        Expanded(
                                            child: Text(
                                                'Doctor: ${c['recommendation']}',
                                                style: const TextStyle(
                                                    fontSize: 13))),
                                      ]),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                      c['created_at']
                                              ?.toString()
                                              .split('T')[0] ??
                                          '',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
