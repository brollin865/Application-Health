import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});
  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  int _touchedIndex = -1;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiService.get('dashboard/doctor');
      setState(() { _stats = res['data']; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        backgroundColor: const Color(0xFF1F4E79),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () { setState(() => _loading=true); _load(); }),
          IconButton(icon: const Icon(Icons.list_alt), onPressed: () => Navigator.pushNamed(context, '/doctor/consults')),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async { await AuthService.logout(); if (mounted) Navigator.pushReplacementNamed(context, '/login'); }),
        ],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Header card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1F4E79), Color(0xFF2E75B6)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFF1F4E79).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0,4))],
                    ),
                    child: Row(children: [
                      const CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.local_hospital, color: Colors.white, size: 30)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Doctor Portal', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('Entebbe General Referral Hospital', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)), child: const Text('ONLINE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                      ])),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  // Stat cards
                  GridView.count(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                    childAspectRatio: 1.6, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _statCard('Total Patients',  '${_stats?["total_patients"]??0}',           Icons.people,          const Color(0xFF2E75B6)),
                      _statCard('Pending',         '${_stats?["pending_consultations"]??0}',    Icons.pending_actions,  Colors.orange),
                      _statCard('Completed',       '${_stats?["completed_consultations"]??0}',  Icons.check_circle,     Colors.green),
                      _statCard('Diagnoses',       '${_stats?["total_diagnoses"]??0}',          Icons.medical_services, Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Charts row
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _barChart()),
                    const SizedBox(width: 12),
                    Expanded(child: _pieChart()),
                  ]),
                  const SizedBox(height: 20),
                  // Pending list
                  _pendingList(),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/doctor/consults'),
                    icon: const Icon(Icons.list_alt),
                    label: const Text('VIEW ALL CONSULTATIONS'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F4E79), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  )),
                ]),
              ),
            ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
        border: Border(left: BorderSide(color: color, width: 4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: color, size: 20), const Spacer(), Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey))]),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }

  Widget _barChart() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Monthly Consultations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F4E79))),
        const SizedBox(height: 14),
        SizedBox(height: 130, child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround, maxY: 20,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
              getTitlesWidget: (v, _) => Text(['J','F','M','A','M','J'][v.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey)))),
          ),
          gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withValues(alpha: 0.15), strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          barGroups: [5.0,8.0,12.0,7.0,15.0,8.0].asMap().entries.map((e) =>
            BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value,
              color: e.key == 4 ? const Color(0xFF1F4E79) : e.key == 5 ? Colors.orange : const Color(0xFF2E75B6),
              width: 14, borderRadius: BorderRadius.circular(4))])).toList(),
        ))),
      ]),
    );
  }

  Widget _pieChart() {
    final data = [('Malaria',35.0,Colors.red),('Typhoid',28.0,Colors.orange),('Flu',20.0,Colors.blue),('Other',17.0,Colors.green)];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Diagnosis Split', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F4E79))),
        const SizedBox(height: 8),
        SizedBox(height: 120, child: PieChart(PieChartData(
          centerSpaceRadius: 25, sectionsSpace: 2,
          pieTouchData: PieTouchData(touchCallback: (_, r) => setState(() => _touchedIndex = r?.touchedSection?.touchedSectionIndex ?? -1)),
          sections: data.asMap().entries.map((e) => PieChartSectionData(
            value: e.value.$2, color: e.value.$3,
            radius: _touchedIndex == e.key ? 52 : 45,
            title: '${e.value.$2.toInt()}%',
            titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
          )).toList(),
        ))),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 4, children: data.map((e) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: e.$3, shape: BoxShape.circle)),
          const SizedBox(width: 3),
          Text(e.$1, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ])).toList()),
      ]),
    );
  }

  Widget _pendingList() {
    final list = (_stats?['recent_consultations'] as List? ?? []).where((c) => c['status'] == 'pending').take(5).toList();
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Pending Consultations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)), child: Text('${list.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
      ]),
      const SizedBox(height: 10),
      ...list.map((c) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orange.withValues(alpha: 0.4))),
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: Color(0xFF1F4E79), child: Icon(Icons.person, color: Colors.white)),
          title: Text(c['patient']?['user']?['name'] ?? 'Patient', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Severity: ${c['severity'] ?? 'Unknown'}  •  ${c['created_at']?.toString().split('T')[0] ?? ''}'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          onTap: () => Navigator.pushNamed(context, '/doctor/consults'),
        ),
      )),
    ]);
  }
}
