import 'package:flutter/material.dart';

class DiagnosisResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  const DiagnosisResultScreen({super.key, required this.results});

  Color _priorityColor(String p) => switch (p) {
    'Critical' => Colors.red[700]!,
    'High'     => Colors.red,
    'Medium'   => Colors.orange,
    _          => Colors.green,
  };

  IconData _priorityIcon(String p) => switch (p) {
    'Critical' => Icons.emergency,
    'High'     => Icons.warning,
    'Medium'   => Icons.info,
    _          => Icons.check_circle,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnosis Results')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.orange[50],
            child: const Row(children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(child: Text('Preliminary results only. Please consult a doctor for confirmation.',
                style: TextStyle(fontSize: 13, color: Colors.orange))),
            ]),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.check_circle, size: 64, color: Colors.green),
                    SizedBox(height: 12),
                    Text('No significant matches found', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Please consult a healthcare professional', style: TextStyle(color: Colors.grey)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final r = results[i];
                      final priority = r['priority'] ?? 'Low';
                      final col = _priorityColor(priority);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: col.withValues(alpha: 0.5), width: 1.5)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              CircleAvatar(backgroundColor: col, radius: 18, child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                              const SizedBox(width: 12),
                              Expanded(child: Text(r['diagnosis'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(20)),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(_priorityIcon(priority), size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(priority, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ]),
                              ),
                            ]),
                            if (r['match_percent'] != null) ...[
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (r['match_percent'] as num) / 100,
                                  backgroundColor: col.withValues(alpha: 0.15),
                                  color: col,
                                  minHeight: 6,
                                ),
                              ),
                              Text('${r['match_percent']}% symptom match', style: TextStyle(fontSize: 12, color: col)),
                            ],
                            const SizedBox(height: 10),
                            if (r['description'] != null) Text(r['description'], style: const TextStyle(color: Colors.black87)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: col.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Icon(Icons.medical_services, size: 16, color: col),
                                const SizedBox(width: 6),
                                Expanded(child: Text(r['recommendation'] ?? '', style: const TextStyle(fontSize: 13))),
                              ]),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pushNamed(context, '/consultations'), child: const Text('View Consultations'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Check Again'))),
            ]),
          ),
        ],
      ),
    );
  }
}
