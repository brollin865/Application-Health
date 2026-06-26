import 'package:flutter/material.dart';

class ConsultationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> consultation;
  const ConsultationDetailScreen({super.key, required this.consultation});

  Color _statusColor(String s) => switch (s) {
        'pending' => Colors.orange,
        'under_review' => Colors.blue,
        'completed' => Colors.green,
        _ => Colors.grey,
      };

  String _formatDate(dynamic raw) {
    if (raw == null) return '—';
    final s = raw.toString();
    return s.contains('T') ? s.split('T')[0] : s;
  }

  Widget _sectionCard(
      {required IconData icon,
      required Color color,
      required String title,
      required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        ]),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = consultation;
    final status = c['status'] ?? 'pending';
    final col = _statusColor(status);
    final severity = c['severity'] ?? 'Unknown';
    final diagnosisName =
        c['diagnosis_name'] ?? c['diagnosis']?['disease_name'];
    final doctorName = c['doctor']?['user']?['name'];

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(title: const Text('Consultation Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1F4E79), Color(0xFF2E75B6)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: col, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                      status.toString().toUpperCase().replaceAll('_', ' '),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text(severity,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ]),
              const SizedBox(height: 10),
              Text('Submitted on ${_formatDate(c['created_at'])}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 16),

          _sectionCard(
            icon: Icons.note_alt_outlined,
            color: const Color(0xFF1F4E79),
            title: 'Notes',
            child: Text(c['notes'] ?? 'No notes provided',
                style: const TextStyle(fontSize: 14)),
          ),

          if (diagnosisName != null)
            _sectionCard(
              icon: Icons.coronavirus_outlined,
              color: Colors.deepPurple,
              title: 'Diagnosis',
              child: Text(diagnosisName,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),

          if (c['recommendation'] != null)
            _sectionCard(
              icon: Icons.medical_services_outlined,
              color: Colors.green,
              title: "Doctor's Recommendation",
              child: Text(c['recommendation'],
                  style: const TextStyle(fontSize: 14)),
            ),

          if (doctorName != null)
            _sectionCard(
              icon: Icons.person_outline,
              color: Colors.teal,
              title: 'Reviewed By',
              child: Text(doctorName, style: const TextStyle(fontSize: 14)),
            ),

          _sectionCard(
            icon: Icons.info_outline,
            color: Colors.grey[700]!,
            title: 'Status',
            child: status == 'completed'
                ? const Text(
                    'This consultation has been reviewed and completed.',
                    style: TextStyle(fontSize: 13, color: Colors.black54))
                : status == 'under_review'
                    ? const Text(
                        'A doctor is currently reviewing this consultation.',
                        style: TextStyle(fontSize: 13, color: Colors.black54))
                    : const Text(
                        'Waiting for a doctor to review this consultation.',
                        style: TextStyle(fontSize: 13, color: Colors.black54)),
          ),
        ]),
      ),
    );
  }
}
