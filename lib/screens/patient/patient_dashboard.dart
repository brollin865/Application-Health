import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

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
      });
    } catch (_) {
      setState(() => _loading = false);
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
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout)
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        selectedItemColor: const Color(0xFF1F4E79),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          setState(() => _tab = i);
          if (i == 1) Navigator.pushNamed(context, '/symptom-checker');
          if (i == 2) Navigator.pushNamed(context, '/consultations');
          if (i == 3) Navigator.pushNamed(context, '/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.medical_services), label: 'Check'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'Consults'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  List<BoxShadow> get _cardShadow => [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4)),
      ];

  Widget _sectionTitle(String text, {IconData? icon}) {
    return Row(children: [
      if (icon != null) ...[
        Icon(icon, size: 18, color: const Color(0xFF1F4E79)),
        const SizedBox(width: 6),
      ],
      Text(text,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2A37))),
    ]);
  }

  Widget _buildBody() {
    final total = _stats?['total_consultations'] ?? 0;
    final pending = _stats?['pending_consultations'] ?? 0;
    final completed = _stats?['completed_consultations'] ?? 0;
    final latest = _stats?['latest_diagnosis'];
    final initial = _name.isNotEmpty ? _name[0].toUpperCase() : '?';

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1F4E79), Color(0xFF2E75B6)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF1F4E79).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Text('Good day,',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                        Text(_name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.local_hospital,
                              color: Colors.white60, size: 13),
                          const SizedBox(width: 4),
                          const Text('Entebbe General Referral Hospital',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 12)),
                        ]),
                      ])),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.18),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(initial,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            // Stat cards
            Row(children: [
              _statCard('Total', total.toString(), Icons.list_alt_rounded,
                  Colors.blue),
              const SizedBox(width: 12),
              _statCard('Pending', pending.toString(),
                  Icons.pending_actions_rounded, Colors.orange),
              const SizedBox(width: 12),
              _statCard('Completed', completed.toString(),
                  Icons.check_circle_rounded, Colors.green),
            ]),
            const SizedBox(height: 24),
            // Latest diagnosis
            if (latest != null) ...[
              _sectionTitle('Latest Diagnosis',
                  icon: Icons.medical_information_outlined),
              const SizedBox(height: 10),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.pushNamed(context, '/consultations'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _cardShadow),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const Icon(Icons.medical_information,
                              color: Colors.red),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(latest['diagnosis'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(latest['recommendation'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 13)),
                            ])),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ]),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Quick actions
            _sectionTitle('Quick Actions', icon: Icons.flash_on_rounded),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _actionCard(
                    'Symptom Checker',
                    Icons.search_rounded,
                    Colors.blue,
                    () => Navigator.pushNamed(context, '/symptom-checker')),
                _actionCard(
                    'My Consultations',
                    Icons.list_alt_rounded,
                    Colors.orange,
                    () => Navigator.pushNamed(context, '/consultations')),
                _actionCard(
                    'Health History',
                    Icons.history_rounded,
                    Colors.green,
                    () => Navigator.pushNamed(context, '/consultations')),
                _actionCard('My Profile', Icons.person_rounded, Colors.purple,
                    () => Navigator.pushNamed(context, '/profile')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _cardShadow),
      child: Column(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    ));
  }

  Widget _actionCard(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16), boxShadow: _cardShadow),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: color, fontSize: 13),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
