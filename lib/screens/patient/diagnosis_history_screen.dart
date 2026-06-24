import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DiagnosisHistoryScreen extends StatefulWidget {
  const DiagnosisHistoryScreen({super.key});
  @override
  State<DiagnosisHistoryScreen> createState() => _DiagnosisHistoryScreenState();
}

class _DiagnosisHistoryScreenState extends State<DiagnosisHistoryScreen> {
  List<dynamic> _history = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiService.get('diagnosis-history');
      setState(() { _history = res['data']; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Color _diagnosisColor(String diagnosis) {
    final d = diagnosis.toLowerCase();
    if (d.contains('malaria'))   return Colors.red;
    if (d.contains('typhoid'))   return Colors.orange;
    if (d.contains('pneumonia')) return Colors.red[700]!;
    if (d.contains('flu') || d.contains('influenza')) return Colors.blue;
    if (d.contains('covid'))     return Colors.purple;
    return const Color(0xFF1F4E79);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        title: const Text('Diagnosis History'),
        backgroundColor: const Color(0xFF1F4E79),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.history, size: 72, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No diagnosis history yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Your past diagnoses will appear here', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/symptom-checker'),
                    icon: const Icon(Icons.search),
                    label: const Text('Start Symptom Check'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F4E79), foregroundColor: Colors.white),
                  ),
                ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: Column(children: [
                    // Summary banner
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1F4E79), Color(0xFF2E75B6)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        const Icon(Icons.history, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Health Timeline', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('${_history.length} diagnosis record${_history.length == 1 ? "" : "s"} found', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ]),
                      ]),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _history.length,
                        itemBuilder: (_, i) {
                          final h = _history[i];
                          final diagnosis = h['diagnosis'] ?? 'Unknown';
                          final color = _diagnosisColor(diagnosis);
                          final date = h['created_at']?.toString().split('T')[0] ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              // Timeline line
                              Column(children: [
                                CircleAvatar(radius: 16, backgroundColor: color, child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                                if (i < _history.length - 1)
                                  Container(width: 2, height: 30, color: Colors.grey[300]),
                              ]),
                              const SizedBox(width: 12),
                              // Card
                              Expanded(child: Card(
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: color.withValues(alpha: 0.3)),
                                ),
                                child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(children: [
                                    Expanded(child: Text(diagnosis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color))),
                                    Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ]),
                                  const SizedBox(height: 8),
                                  if (h['recommendation'] != null)
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
                                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Icon(Icons.medical_services, size: 15, color: color),
                                        const SizedBox(width: 6),
                                        Expanded(child: Text(h['recommendation'], style: const TextStyle(fontSize: 13))),
                                      ]),
                                    ),
                                ])),
                              )),
                            ]),
                          );
                        },
                      ),
                    ),
                  ]),
                ),
    );
  }
}
