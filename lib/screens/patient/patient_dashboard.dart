import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/dashboard_widgets.dart';

const List<(IconData, String, String)> _kHealthTips = [
  (Icons.local_drink_rounded, 'Stay hydrated', 'Aim for 6–8 glasses of water a day'),
  (Icons.bedtime_rounded, 'Sleep well', '7–9 hours keeps your immune system strong'),
  (Icons.directions_walk_rounded, 'Keep moving', '30 minutes of activity most days'),
  (Icons.wash_rounded, 'Wash your hands', 'Reduces your risk of common infections'),
];

const _kNavy = Color(0xFF1F4E79);
const _kBlue = Color(0xFF2E75B6);

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});
  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _tab = 0;
  Map<String, dynamic>? _stats;
  String _name = '';
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('user_name') ?? '';
    try {
      final res = await ApiService.get('dashboard/patient');
      setState(() {
        _stats = res['data'];
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        backgroundColor: _kNavy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kNavy))
          : _buildBody(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _tab,
        activeColor: _kNavy,
        onTap: (i) {
          setState(() => _tab = i);
          if (i == 1) Navigator.pushNamed(context, '/symptom-checker');
          if (i == 2) Navigator.pushNamed(context, '/consultations');
          if (i == 3) Navigator.pushNamed(context, '/profile');
        },
        items: const [
          AppBottomNavItem(icon: Icons.home_rounded, label: 'Home'),
          AppBottomNavItem(icon: Icons.medical_services_rounded, label: 'Check'),
          AppBottomNavItem(icon: Icons.list_alt_rounded, label: 'Consults'),
          AppBottomNavItem(icon: Icons.person_rounded, label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final total = _stats?['total_consultations'] ?? 0;
    final pending = _stats?['pending_consultations'] ?? 0;
    final completed = _stats?['completed_consultations'] ?? 0;
    final latest = _stats?['latest_diagnosis'];
    final initial = _name.isNotEmpty ? _name[0].toUpperCase() : '?';

    return RefreshIndicator(
      onRefresh: _load,
      color: _kNavy,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(
              child: GradientHeaderCard(
                colors: const [_kNavy, _kBlue],
                leading: InitialsAvatar(initial: initial),
                title: '${greetingForNow()}, $_name',
                subtitle: 'Entebbe General Referral Hospital',
                footer: Row(children: [
                  Icon(Icons.calendar_today_rounded, color: Colors.white.withValues(alpha: 0.7), size: 12),
                  const SizedBox(width: 6),
                  Text(DateFormat('EEEE, d MMMM').format(DateTime.now()), style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                ]),
              ),
            ),
            if (_failed) ...[
              const SizedBox(height: 14),
              InlineNotice(message: 'Showing cached data — couldn\'t refresh just now.', onRetry: _load),
            ],
            const SizedBox(height: 22),
            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: Row(children: [
                Expanded(child: _tappableStat(StatCard(label: 'Total', value: total.toString(), icon: Icons.list_alt_rounded, color: Colors.blue))),
                const SizedBox(width: 12),
                Expanded(child: _tappableStat(StatCard(label: 'Pending', value: pending.toString(), icon: Icons.pending_actions_rounded, color: Colors.orange))),
                const SizedBox(width: 12),
                Expanded(child: _tappableStat(StatCard(label: 'Completed', value: completed.toString(), icon: Icons.check_circle_rounded, color: Colors.green))),
              ]),
            ),
            const SizedBox(height: 24),
            FadeSlideIn(
              delay: const Duration(milliseconds: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Latest Diagnosis', icon: Icons.medical_information_outlined),
                  const SizedBox(height: 10),
                  if (latest != null)
                    InkWell(
                      borderRadius: BorderRadius.circular(kDashboardRadius),
                      onTap: () => Navigator.pushNamed(context, '/consultations'),
                      child: DashboardCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: const Icon(Icons.medical_information, color: Colors.red),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(latest['diagnosis'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text(latest['recommendation'] ?? '', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    )
                  else
                    InkWell(
                      borderRadius: BorderRadius.circular(kDashboardRadius),
                      onTap: () => Navigator.pushNamed(context, '/symptom-checker'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(kDashboardRadius),
                          boxShadow: kDashboardShadow,
                          border: Border.all(color: const Color(0xFFE1E7EF)),
                        ),
                        child: Row(children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: _kBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: const Icon(Icons.search_rounded, color: _kBlue),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('No diagnosis yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF1F2A37))),
                                SizedBox(height: 3),
                                Text('Run a symptom check to get your first result', style: TextStyle(color: Colors.grey, fontSize: 12.5)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Quick Actions', icon: Icons.flash_on_rounded),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: [
                      ActionTile(
                        label: 'Symptom Checker',
                        icon: Icons.search_rounded,
                        color: Colors.blue,
                        onTap: () => Navigator.pushNamed(context, '/symptom-checker'),
                      ),
                      ActionTile(
                        label: 'My Consultations',
                        icon: Icons.list_alt_rounded,
                        color: Colors.orange,
                        onTap: () => Navigator.pushNamed(context, '/consultations'),
                      ),
                      ActionTile(
                        label: 'Health History',
                        icon: Icons.history_rounded,
                        color: Colors.green,
                        onTap: () => Navigator.pushNamed(context, '/consultations'),
                      ),
                      ActionTile(
                        label: 'My Profile',
                        icon: Icons.person_rounded,
                        color: Colors.purple,
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeSlideIn(
              delay: const Duration(milliseconds: 260),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Health Tips', icon: Icons.tips_and_updates_outlined),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 118,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _kHealthTips.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final (icon, title, desc) = _kHealthTips[i];
                        return Container(
                          width: 200,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(kDashboardRadius), boxShadow: kDashboardShadow),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(icon, color: _kBlue, size: 22),
                              const SizedBox(height: 8),
                              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2A37))),
                              const SizedBox(height: 3),
                              Text(desc, style: TextStyle(fontSize: 11.5, color: Colors.grey[600], height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tappableStat(Widget child) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(kDashboardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(kDashboardRadius),
        onTap: () => Navigator.pushNamed(context, '/consultations'),
        child: child,
      ),
    );
  }
}
