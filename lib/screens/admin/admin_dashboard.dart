import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiService.get('dashboard/admin');
      setState(() { _stats = res['data']; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF4A0080),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () { setState(() => _loading=true); _load(); }),
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
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF4A0080), Color(0xFF7030A0)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.purple.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0,4))],
                    ),
                    child: Row(children: [
                      const CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 30)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Administrator Panel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('Entebbe General Referral Hospital', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)), child: const Text('SYSTEM ONLINE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                      ])),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  // Stat cards
                  GridView.count(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                    childAspectRatio: 1.55, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _card('Total Users',     '${_stats?["total_users"]??0}',         Icons.group,             Colors.blue),
                      _card('Patients',        '${_stats?["total_patients"]??0}',       Icons.personal_injury,   Colors.teal),
                      _card('Doctors',         '${_stats?["doctors"]??0}',              Icons.local_hospital,    Colors.purple),
                      _card('Consultations',   '${_stats?["total_consultations"]??0}',  Icons.chat_bubble_outline, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Line chart
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('System Activity — Last 6 Months', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4A0080))),
                      const SizedBox(height: 14),
                      SizedBox(height: 160, child: LineChart(LineChartData(
                        gridData: FlGridData(drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withValues(alpha: 0.15), strokeWidth: 1)),
                        titlesData: FlTitlesData(
                          leftTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
                            getTitlesWidget: (v, _) => Text(['J','F','M','A','M','J'][v.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0, maxX: 5, minY: 0, maxY: 35,
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [FlSpot(0,8),FlSpot(1,15),FlSpot(2,22),FlSpot(3,18),FlSpot(4,30),FlSpot(5,25)],
                            isCurved: true, color: Colors.purple, barWidth: 2.5,
                            belowBarData: BarAreaData(show: true, color: Colors.purple.withValues(alpha: 0.1)),
                            dotData: const FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: const [FlSpot(0,5),FlSpot(1,9),FlSpot(2,14),FlSpot(3,11),FlSpot(4,20),FlSpot(5,18)],
                            isCurved: true, color: Colors.teal, barWidth: 2.5,
                            belowBarData: BarAreaData(show: true, color: Colors.teal.withValues(alpha: 0.1)),
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ))),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _legend('Consultations', Colors.purple),
                        const SizedBox(width: 16),
                        _legend('New Patients', Colors.teal),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  // Quick links
                  const Text('System Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                    childAspectRatio: 2.2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _quickLink('Manage Users',    Icons.group,           Colors.blue),
                      _quickLink('Consultations',   Icons.list_alt,         Colors.orange),
                      _quickLink('Symptoms DB',     Icons.medical_services, Colors.teal),
                      _quickLink('Diagnoses DB',    Icons.biotech,          Colors.purple),
                    ],
                  ),
                ]),
              ),
            ),
    );
  }

  Widget _card(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
        border: Border(left: BorderSide(color: color, width: 4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: color, size: 20), const Spacer(), Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey))]),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }

  Widget _legend(String label, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 14, height: 3, color: color), const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
  ]);

  Widget _quickLink(String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
    child: Row(children: [Icon(icon, color: color, size: 22), const SizedBox(width: 8), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13))]),
  );
}
