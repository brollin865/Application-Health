import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/dashboard_widgets.dart';
import 'diagnosis_result_screen.dart';

const _kNavy = Color(0xFF1F4E79);
const _kBlue = Color(0xFF2E75B6);

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});
  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  List<dynamic> _symptoms = [];
  final Set<int> _selected = {};
  bool _loading = true;
  bool _checking = false;
  String _query = '';

  @override
  void initState() { super.initState(); _loadSymptoms(); }

  Future<void> _loadSymptoms() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('symptoms');
      setState(() { _symptoms = res['data']; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  Future<void> _check() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one symptom')));
      return;
    }
    setState(() => _checking = true);
    try {
      final res = await ApiService.post('symptom-checker', {'symptom_ids': _selected.toList()});
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => DiagnosisResultScreen(results: List<Map<String, dynamic>>.from(res['results'])),
      ));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  List<dynamic> get _filtered => _query.isEmpty
      ? _symptoms
      : _symptoms.where((s) => (s['name'] as String).toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(title: const Text('Symptom Checker')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kNavy))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: FadeSlideIn(
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(kDashboardRadius), boxShadow: kDashboardShadow),
                        child: Row(children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: _kBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.center,
                            child: const Icon(Icons.info_outline_rounded, color: _kBlue, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('Select all the symptoms that apply to you', style: TextStyle(fontSize: 13, color: Color(0xFF1F2A37), fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _selected.isEmpty ? Colors.grey[200] : _kNavy,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${_selected.length}', style: TextStyle(color: _selected.isEmpty ? Colors.grey[600] : Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Search symptoms',
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13.5),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[500], size: 21),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(kDashboardRadius), borderSide: BorderSide.none),
                        ),
                      ),
                    ]),
                  ),
                ),
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(_symptoms.isEmpty ? Icons.medical_services_outlined : Icons.search_off_rounded, size: 44, color: Colors.grey[350]),
                            const SizedBox(height: 12),
                            Text(_symptoms.isEmpty ? 'No symptoms available' : 'No symptoms match "$_query"', style: const TextStyle(color: Colors.grey)),
                          ]),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final s = _filtered[i];
                            final id = s['id'] as int;
                            final selected = _selected.contains(id);
                            return FadeSlideIn(
                              delay: Duration(milliseconds: 30 * i.clamp(0, 10)),
                              child: _symptomTile(s, id, selected),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: (_checking || _selected.isEmpty) ? null : const LinearGradient(colors: [_kNavy, _kBlue]),
                        color: (_checking || _selected.isEmpty) ? Colors.grey[300] : null,
                        boxShadow: (_checking || _selected.isEmpty)
                            ? null
                            : [BoxShadow(color: _kNavy.withValues(alpha: 0.32), blurRadius: 16, offset: const Offset(0, 8))],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: (_checking || _selected.isEmpty) ? null : _check,
                          child: Center(
                            child: _checking
                                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: _kNavy, strokeWidth: 2.4))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search_rounded, color: _selected.isEmpty ? Colors.grey[600] : Colors.white, size: 19),
                                      const SizedBox(width: 8),
                                      Text(
                                        'CHECK SYMPTOMS (${_selected.length})',
                                        style: TextStyle(
                                          color: _selected.isEmpty ? Colors.grey[600] : Colors.white,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
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
    );
  }

  Widget _symptomTile(Map s, int id, bool selected) {
    final desc = s['description'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDashboardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(kDashboardRadius),
          onTap: () => setState(() => selected ? _selected.remove(id) : _selected.add(id)),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kDashboardRadius),
              boxShadow: kDashboardShadow,
              border: Border.all(color: selected ? _kNavy : Colors.transparent, width: 1.4),
              color: selected ? _kNavy.withValues(alpha: 0.04) : Colors.white,
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24, height: 24,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? _kNavy : Colors.transparent,
                  border: Border.all(color: selected ? _kNavy : Colors.grey[350]!, width: 1.6),
                ),
                child: selected ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s['name'], style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.w600, fontSize: 14.5, color: const Color(0xFF1F2A37))),
                  if (desc != null) ...[
                    const SizedBox(height: 3),
                    Text(desc, style: TextStyle(fontSize: 12.5, color: Colors.grey[600], height: 1.3)),
                  ],
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
