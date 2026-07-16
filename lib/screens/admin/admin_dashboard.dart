import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/dashboard_widgets.dart';

const _kPurpleDark = Color(0xFF4A0080);
const _kPurple = Color(0xFF7030A0);

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiService.get('dashboard/admin');
      setState(() { _stats = res['data']; _loading = false; _failed = false; });
    } catch (_) { setState(() { _loading = false; _failed = true; }); }
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming soon'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: _kPurpleDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () { setState(() => _loading = true); _load(); }),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async { await AuthService.logout(); if (mounted) Navigator.pushReplacementNamed(context, '/login'); }),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kPurpleDark))
          : RefreshIndicator(
              onRefresh: _load,
              color: _kPurpleDark,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FadeSlideIn(
                      child: GradientHeaderCard(
                        colors: [_kPurpleDark, _kPurple],
                        leading: CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 30)),
                        title: 'Administrator Panel',
                        subtitle: 'Entebbe General Referral Hospital',
                        footer: StatusPill(label: 'SYSTEM ONLINE'),
                      ),
                    ),
                    if (_failed) ...[
                      const SizedBox(height: 14),
                      InlineNotice(message: 'Showing cached data — couldn\'t refresh just now.', onRetry: _load),
                    ],
                    const SizedBox(height: 20),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 80),
                      child: GridView.count(
                        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                        childAspectRatio: 1.15, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        children: [
                          StatCard(label: 'Total Users', value: '${_stats?["total_users"] ?? 0}', icon: Icons.group, color: Colors.blue),
                          StatCard(label: 'Patients', value: '${_stats?["total_patients"] ?? 0}', icon: Icons.personal_injury, color: Colors.teal),
                          StatCard(label: 'Doctors', value: '${_stats?["doctors"] ?? 0}', icon: Icons.local_hospital, color: _kPurple),
                          StatCard(label: 'Consultations', value: '${_stats?["total_consultations"] ?? 0}', icon: Icons.chat_bubble_outline, color: Colors.orange),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 140),
                      child: DashboardCard(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('System Activity — Last 6 Months', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _kPurpleDark)),
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
                                isCurved: true, color: _kPurple, barWidth: 2.5,
                                belowBarData: BarAreaData(show: true, color: _kPurple.withValues(alpha: 0.1)),
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
                          const SizedBox(height: 10),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            _legend('Consultations', _kPurple),
                            const SizedBox(width: 16),
                            _legend('New Patients', Colors.teal),
                          ]),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'System Management', icon: Icons.settings_suggest_rounded, iconColor: _kPurpleDark),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                            childAspectRatio: 2.5, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                            children: [
                              ActionTile(label: 'Manage Users', icon: Icons.group, color: Colors.blue, onTap: () => _comingSoon('User management')),
                              ActionTile(label: 'Consultations', icon: Icons.list_alt, color: Colors.orange, onTap: () => _comingSoon('Consultation management')),
                              ActionTile(label: 'Symptoms DB', icon: Icons.medical_services, color: Colors.teal, onTap: () => _comingSoon('Symptoms database')),
                              ActionTile(label: 'Diagnoses DB', icon: Icons.biotech, color: _kPurple, onTap: () => _comingSoon('Diagnoses database')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _legend(String label, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 14, height: 3, color: color), const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
  ]);
}
