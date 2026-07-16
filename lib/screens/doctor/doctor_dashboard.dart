import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/dashboard_widgets.dart';

const _kNavy = Color(0xFF1F4E79);
const _kBlue = Color(0xFF2E75B6);

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});
  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  bool _failed = false;
  int _touchedIndex = -1;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiService.get('dashboard/doctor');
      setState(() { _stats = res['data']; _loading = false; _failed = false; });
    } catch (_) { setState(() { _loading = false; _failed = true; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        backgroundColor: _kNavy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () { setState(() => _loading = true); _load(); }),
          IconButton(icon: const Icon(Icons.list_alt), onPressed: () => Navigator.pushNamed(context, '/doctor/consults')),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async { await AuthService.logout(); if (mounted) Navigator.pushReplacementNamed(context, '/login'); }),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kNavy))
          : RefreshIndicator(
              onRefresh: _load,
              color: _kNavy,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FadeSlideIn(
                      child: GradientHeaderCard(
                        colors: [_kNavy, _kBlue],
                        leading: CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.local_hospital, color: Colors.white, size: 30)),
                        title: 'Doctor Portal',
                        subtitle: 'Entebbe General Referral Hospital',
                        footer: StatusPill(label: 'ONLINE'),
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
                          StatCard(label: 'Total Patients', value: '${_stats?["total_patients"] ?? 0}', icon: Icons.people, color: _kBlue),
                          StatCard(label: 'Pending', value: '${_stats?["pending_consultations"] ?? 0}', icon: Icons.pending_actions, color: Colors.orange),
                          StatCard(label: 'Completed', value: '${_stats?["completed_consultations"] ?? 0}', icon: Icons.check_circle, color: Colors.green),
                          StatCard(label: 'Diagnoses', value: '${_stats?["total_diagnoses"] ?? 0}', icon: Icons.medical_services, color: Colors.purple),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 140),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(child: _barChart()),
                        const SizedBox(width: 12),
                        Expanded(child: _pieChart()),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    FadeSlideIn(delay: const Duration(milliseconds: 200), child: _pendingList()),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 240),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(kDashboardRadius),
                            gradient: const LinearGradient(colors: [_kNavy, _kBlue]),
                            boxShadow: [BoxShadow(color: _kNavy.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 6))],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(kDashboardRadius),
                              onTap: () => Navigator.pushNamed(context, '/doctor/consults'),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.list_alt, color: Colors.white, size: 19),
                                    SizedBox(width: 8),
                                    Text('VIEW ALL CONSULTATIONS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _barChart() {
    return DashboardCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Monthly Consultations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _kNavy)),
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
              color: e.key == 4 ? _kNavy : e.key == 5 ? Colors.orange : _kBlue,
              width: 14, borderRadius: BorderRadius.circular(4))])).toList(),
        ))),
      ]),
    );
  }

  Widget _pieChart() {
    final data = [('Malaria',35.0,Colors.red),('Typhoid',28.0,Colors.orange),('Flu',20.0,Colors.blue),('Other',17.0,Colors.green)];
    return DashboardCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Diagnosis Split', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _kNavy)),
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
      SectionHeader(
        title: 'Pending Consultations',
        icon: Icons.pending_actions_rounded,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)),
          child: Text('${list.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
      const SizedBox(height: 10),
      ...list.map((c) {
        final name = c['patient']?['user']?['name'] ?? 'Patient';
        final patientInitial = (name as String).isNotEmpty ? name[0].toUpperCase() : '?';
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(kDashboardRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(kDashboardRadius),
              onTap: () => Navigator.pushNamed(context, '/doctor/consults'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kDashboardRadius),
                  boxShadow: kDashboardShadow,
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
                ),
                child: Row(children: [
                  CircleAvatar(backgroundColor: _kNavy, child: Text(patientInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('Severity: ${c['severity'] ?? 'Unknown'}  •  ${c['created_at']?.toString().split('T')[0] ?? ''}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ]),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ]),
              ),
            ),
          ),
        );
      }),
    ]);
  }
}
