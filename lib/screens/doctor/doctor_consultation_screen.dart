import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/dashboard_widgets.dart';

const _kNavy = Color(0xFF1F4E79);
const _kBlue = Color(0xFF2E75B6);

class DoctorConsultationScreen extends StatefulWidget {
  const DoctorConsultationScreen({super.key, this.initialFilter = 'all'});
  final String initialFilter;
  @override
  State<DoctorConsultationScreen> createState() => _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState extends State<DoctorConsultationScreen> {
  List<dynamic> _consultations = [];
  List<dynamic> _diagnoses = [];
  Map<int, String> _symptomNames = {};
  bool _loading = true;
  late String _filter = widget.initialFilter;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ApiService.get('consultations'),
        ApiService.get('diagnoses'),
        ApiService.get('symptoms'),
      ]);
      final symptoms = results[2]['data'] as List;
      setState(() {
        _consultations = results[0]['data'];
        _diagnoses = results[1]['data'];
        _symptomNames = {for (final s in symptoms) s['id'] as int: s['name'] as String};
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  List<String> _symptomsFor(Map consultation) {
    final ids = consultation['symptoms'];
    if (ids is! List) return const [];
    return ids.map((id) => _symptomNames[id] ?? 'Unknown').toList();
  }

  void _openReview(Map consultation) {
    int? selectedDiagId;
    final recCtrl = TextEditingController(text: consultation['recommendation'] ?? '');
    String status = consultation['status'] ?? 'pending';
    final patientName = consultation['patient']?['user']?['name'] ?? 'Unknown';
    final patientInitial = (patientName as String).isNotEmpty ? patientName[0].toUpperCase() : '?';
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(builder: (ctx, setS) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFEEF2F7),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(color: Colors.grey[350], borderRadius: BorderRadius.circular(4))),
            ),
            Row(children: [
              CircleAvatar(radius: 22, backgroundColor: _kNavy, child: Text(patientInitial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Review Consultation', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1F2A37))),
                Text(patientName, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ])),
            ]),
            const SizedBox(height: 16),
            DashboardCard(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.local_fire_department_rounded, size: 16, color: _statusColor(status)),
                  const SizedBox(width: 6),
                  Text('Severity: ${consultation['severity'] ?? '—'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                ]),
                const SizedBox(height: 10),
                Text('Reported Symptoms', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 6),
                Builder(builder: (_) {
                  final symptoms = _symptomsFor(consultation);
                  if (symptoms.isEmpty) {
                    return Text(consultation['notes'] ?? 'No symptoms recorded', style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4));
                  }
                  return Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: symptoms.map((name) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: _kBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(name, style: const TextStyle(color: _kNavy, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    )).toList(),
                  );
                }),
                if ((consultation['notes'] as String?)?.isNotEmpty == true && _symptomsFor(consultation).isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text('Notes: ${consultation['notes']}', style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4)),
                ],
              ]),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Assign Formal Diagnosis',
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: _diagnoses.map<DropdownMenuItem<int>>((d) => DropdownMenuItem(value: d['id'] as int, child: Text(d['disease_name']))).toList(),
              onChanged: (v) => setS(() => selectedDiagId = v),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: recCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Clinical Recommendation',
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1F2A37))),
            const SizedBox(height: 8),
            Row(children: ['pending','under_review','completed'].map((s) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(s.replaceAll('_', ' '), style: const TextStyle(fontSize: 11)),
                  selected: status == s,
                  onSelected: (_) => setS(() => status = s),
                  selectedColor: _statusColor(s),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: status == s ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _statusColor(s).withValues(alpha: 0.4))),
                ),
              ),
            )).toList()),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kDashboardRadius),
                  gradient: saving ? null : const LinearGradient(colors: [_kNavy, _kBlue]),
                  color: saving ? Colors.grey[300] : null,
                  boxShadow: saving ? null : [BoxShadow(color: _kNavy.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 6))],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(kDashboardRadius),
                    onTap: saving ? null : () async {
                      setS(() => saving = true);
                      try {
                        final diagName = _diagnoses.firstWhere((d) => d['id'] == selectedDiagId, orElse: () => {})['disease_name'];
                        await ApiService.put('consultations/${consultation['id']}', {
                          'diagnosis_id': selectedDiagId,
                          'diagnosis_name': diagName ?? '',
                          'recommendation': recCtrl.text,
                          'status': status,
                        });
                        if (!mounted) return;
                        Navigator.pop(ctx);
                        _load();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Consultation updated!'), backgroundColor: Colors.green));
                      } catch (e) {
                        setS(() => saving = false);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                      }
                    },
                    child: Center(
                      child: saving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: _kNavy, strokeWidth: 2.4))
                          : const Text('SAVE & UPDATE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
          ]),
        )),
      ),
    );
  }

  Color _statusColor(String s) => switch (s) {
    'pending'      => Colors.orange,
    'under_review' => Colors.blue,
    'completed'    => Colors.green,
    _              => Colors.grey,
  };

  List<dynamic> get _filtered =>
      _filter == 'all' ? _consultations : _consultations.where((c) => (c['status'] ?? 'pending') == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final total = _consultations.length;
    final pending = _consultations.where((c) => (c['status'] ?? 'pending') == 'pending').length;
    final completed = _consultations.where((c) => c['status'] == 'completed').length;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(title: const Text('All Consultations')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kNavy))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: FadeSlideIn(
                    child: Column(children: [
                      Row(children: [
                        Expanded(child: StatCard(label: 'Total', value: '$total', icon: Icons.list_alt_rounded, color: _kBlue)),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(label: 'Pending', value: '$pending', icon: Icons.pending_actions_rounded, color: Colors.orange)),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(label: 'Completed', value: '$completed', icon: Icons.check_circle_rounded, color: Colors.green)),
                      ]),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 8,
                          children: [
                            _filterChip('all', 'All'),
                            _filterChip('pending', 'Pending'),
                            _filterChip('under_review', 'Under Review'),
                            _filterChip('completed', 'Completed'),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    color: _kNavy,
                    child: _filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(Icons.inbox_rounded, size: 48, color: Colors.grey[350]),
                                    const SizedBox(height: 12),
                                    Text(
                                      _filter == 'all' ? 'No consultations found' : 'No ${_filter.replaceAll('_', ' ')} consultations',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ]),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => FadeSlideIn(
                              delay: Duration(milliseconds: 40 * i.clamp(0, 8)),
                              child: _consultationTile(_filtered[i]),
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12.5)),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: _kNavy,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(color: selected ? Colors.white : const Color(0xFF1F2A37), fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: selected ? _kNavy : Colors.grey.withValues(alpha: 0.3))),
      elevation: 0,
    );
  }

  Widget _consultationTile(Map c) {
    final status = c['status'] ?? 'pending';
    final col = _statusColor(status);
    final name = c['patient']?['user']?['name'] ?? 'Patient';
    final initial = (name as String).isNotEmpty ? name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDashboardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(kDashboardRadius),
          onTap: () => _openReview(Map<String, dynamic>.from(c)),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kDashboardRadius),
              boxShadow: kDashboardShadow,
              border: Border(left: BorderSide(color: col, width: 4)),
            ),
            child: Row(children: [
              CircleAvatar(radius: 22, backgroundColor: col.withValues(alpha: 0.15), child: Text(initial, style: TextStyle(color: col, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF1F2A37))),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.local_fire_department_rounded, size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 3),
                    Text('${c['severity'] ?? 'Unknown'}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(width: 10),
                    Icon(Icons.calendar_today_rounded, size: 11, color: Colors.grey[500]),
                    const SizedBox(width: 3),
                    Text(c['created_at']?.toString().split('T')[0] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ]),
                ]),
              ),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: col.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(status.toUpperCase().replaceAll('_', ' '), style: TextStyle(color: col, fontSize: 9.5, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey[400]),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
