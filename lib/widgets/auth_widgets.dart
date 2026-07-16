import 'package:flutter/material.dart';

const kAuthNavy = Color(0xFF1F4E79);
const kAuthBlue = Color(0xFF2E75B6);

const String kHospitalImageAsset = 'assets/images/entebbe_general_hospital.jpg';

/// OmniCare brand mark — a rounded navy square, white disc and cross with a
/// cyan accent stroke. Painted natively so it stays crisp at any size
/// without pulling in an SVG-rendering package.
class OmniCareLogo extends StatelessWidget {
  const OmniCareLogo({super.key, this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size, child: CustomPaint(painter: _OmniCareLogoPainter()));
  }
}

class _OmniCareLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 200;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(42 * s)),
      Paint()..color = const Color(0xFF0F3B7A),
    );
    canvas.drawCircle(Offset(100 * s, 100 * s), 70 * s, Paint()..color = const Color(0xFFF8FBFF));

    final crossPaint = Paint()
      ..color = const Color(0xFF1D4ED8)
      ..strokeWidth = 16 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(100 * s, 58 * s), Offset(100 * s, 142 * s), crossPaint);
    canvas.drawLine(Offset(58 * s, 100 * s), Offset(142 * s, 100 * s), crossPaint);

    final accentPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 10 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(76 * s, 77 * s), Offset(124 * s, 125 * s), accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Framed photo of the hospital, used to ground the brand panel / compact
/// header in the real building instead of abstract iconography alone.
class HospitalImageCard extends StatelessWidget {
  const HospitalImageCard({super.key, this.height = 150});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.asset(kHospitalImageAsset, height: height, width: double.infinity, fit: BoxFit.cover),
      ),
    );
  }
}

/// Full-bleed gradient background with soft decorative blobs, used behind
/// every auth screen (login, register).
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kAuthNavy, kAuthBlue],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -80, left: -60, child: _blob(220, Colors.white.withValues(alpha: 0.06))),
          Positioned(bottom: -100, right: -80, child: _blob(300, Colors.white.withValues(alpha: 0.05))),
          Positioned(top: 120, right: 60, child: _blob(90, Colors.white.withValues(alpha: 0.05))),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

/// Gradient marketing panel shown alongside the form on wide screens.
class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kAuthNavy, kAuthBlue],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50, right: -50,
            child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.07))),
          ),
          Positioned(
            bottom: -60, left: -40,
            child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                      child: const OmniCareLogo(size: 40),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('OmniCare', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Connected hospital care', style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const HospitalImageCard(height: 160),
                const SizedBox(height: 20),
                const Text('Entebbe General Referral Hospital', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'A calm, modern care experience designed to support staff and patients alike.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13.5, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact stacked brand mark shown above the form on narrow screens.
class AuthCompactBrandHeader extends StatelessWidget {
  const AuthCompactBrandHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: kAuthNavy.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 8))],
          ),
          child: const OmniCareLogo(size: 60),
        ),
        const SizedBox(height: 14),
        const Text('OmniCare', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kAuthNavy)),
        const SizedBox(height: 4),
        Text('Healthcare access made simple', style: TextStyle(fontSize: 12.5, color: Colors.grey[600])),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(kHospitalImageAsset, height: 110, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 10),
        Text('Entebbe General Referral Hospital', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
      ],
    );
  }
}

/// Shared white rounded shell that lays the brand panel + form out as a
/// split card on wide screens, or stacked on narrow ones. Wraps the whole
/// thing in the fade/slide entrance used across auth screens.
class AuthCard extends StatefulWidget {
  const AuthCard({super.key, required this.form});
  final Widget form;

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
  late final Animation<double> _fade = CurvedAnimation(parent: _anim, curve: const Interval(0, 0.8, curve: Curves.easeOut));
  late final Animation<Offset> _slide =
      Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Container(
                    width: wide ? 900 : 440,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: kAuthNavy.withValues(alpha: 0.25), blurRadius: 40, offset: const Offset(0, 20))],
                    ),
                    child: wide
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Expanded(flex: 5, child: AuthBrandPanel()),
                                  Expanded(
                                    flex: 6,
                                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 48), child: widget.form),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const AuthCompactBrandHeader(),
                                  const SizedBox(height: 28),
                                  widget.form,
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Consistent rounded input styling shared across auth forms.
InputDecoration authFieldDecoration({required String label, required IconData icon, Widget? suffix}) {
  OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 21),
    suffixIcon: suffix,
    filled: true,
    fillColor: const Color(0xFFF6F8FB),
    border: border(const Color(0xFFE1E7EF), 1),
    enabledBorder: border(const Color(0xFFE1E7EF), 1),
    focusedBorder: border(kAuthBlue, 1.6),
    errorBorder: border(Colors.red.shade300, 1),
    focusedErrorBorder: border(Colors.red.shade400, 1.6),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  );
}

/// Animated-height error banner shared across auth forms.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.error});
  final String? error;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: error == null
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red[200]!)),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[400], size: 19),
                  const SizedBox(width: 8),
                  Expanded(child: Text(error!, style: TextStyle(color: Colors.red[700], fontSize: 13))),
                ],
              ),
            ),
    );
  }
}

/// Gradient primary CTA button shared across auth forms.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({super.key, required this.label, required this.loading, required this.onTap});
  final String label;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: loading ? null : const LinearGradient(colors: [kAuthNavy, kAuthBlue]),
          color: loading ? Colors.grey[300] : null,
          boxShadow: loading ? null : [BoxShadow(color: kAuthNavy.withValues(alpha: 0.32), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: loading ? null : onTap,
            child: Center(
              child: loading
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: kAuthNavy, strokeWidth: 2.4))
                  : Text(label, style: const TextStyle(fontSize: 15.5, letterSpacing: 1.2, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
