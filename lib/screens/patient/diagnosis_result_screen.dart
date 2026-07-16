import 'package:flutter/material.dart';
import '../../widgets/dashboard_widgets.dart';

const _kNavy = Color(0xFF1F4E79);
const _kBlue = Color(0xFF2E75B6);

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
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(title: const Text('Diagnosis Results')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: FadeSlideIn(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(kDashboardRadius),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Icon(Icons.warning_amber_rounded, color: Colors.amber[800], size: 19),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Preliminary results only. Please consult a doctor for confirmation.',
                      style: TextStyle(fontSize: 12.5, color: Colors.amber[900], fontWeight: FontWeight.w500),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 84, height: 84,
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.12), shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: const Icon(Icons.check_circle_rounded, size: 46, color: Colors.green),
                      ),
                      const SizedBox(height: 16),
                      const Text('No significant matches found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1F2A37))),
                      const SizedBox(height: 4),
                      Text('Please consult a healthcare professional', style: TextStyle(color: Colors.grey[600])),
                    ]),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (_, i) {
                      final r = results[i];
                      final priority = r['priority'] ?? 'Low';
                      final col = _priorityColor(priority);
                      return FadeSlideIn(
                        delay: Duration(milliseconds: 60 * i.clamp(0, 8)),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(kDashboardRadius + 2),
                            boxShadow: kDashboardShadow,
                            border: Border(top: BorderSide(color: col, width: 3)),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              CircleAvatar(backgroundColor: col.withValues(alpha: 0.15), radius: 18, child: Text('${i + 1}', style: TextStyle(color: col, fontWeight: FontWeight.bold))),
                              const SizedBox(width: 12),
                              Expanded(child: Text(r['diagnosis'] ?? '', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1F2A37)))),
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
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (r['match_percent'] as num) / 100,
                                  backgroundColor: col.withValues(alpha: 0.12),
                                  color: col,
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('${r['match_percent']}% symptom match', style: TextStyle(fontSize: 12, color: col, fontWeight: FontWeight.w600)),
                            ],
                            if (r['description'] != null) ...[
                              const SizedBox(height: 10),
                              Text(r['description'], style: const TextStyle(color: Colors.black87, fontSize: 13.5, height: 1.4)),
                            ],
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: col.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Icon(Icons.medical_services_rounded, size: 16, color: col),
                                const SizedBox(width: 8),
                                Expanded(child: Text(r['recommendation'] ?? '', style: const TextStyle(fontSize: 13, height: 1.4))),
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
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/consultations'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kNavy,
                      side: const BorderSide(color: _kNavy, width: 1.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('View Consultations', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [_kNavy, _kBlue]),
                      boxShadow: [BoxShadow(color: _kNavy.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.pop(context),
                        child: const Center(
                          child: Text('Check Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
