import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;
    if (loggedIn) {
      final role = await AuthService.getRole();
      if (!mounted) return;
      if (role == 'doctor') {
        Navigator.pushReplacementNamed(context, '/doctor');
      } else if (role == 'admin') Navigator.pushReplacementNamed(context, '/admin');
      else                      Navigator.pushReplacementNamed(context, '/patient');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0D2137), Color(0xFF1F4E79), Color(0xFF2E75B6)],
          ),
        ),
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: const Icon(Icons.health_and_safety, size: 64, color: Colors.white),
              ),
              const SizedBox(height: 28),
              const Text('HealthMonitor', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
              const Text('Diagnosis System', style: TextStyle(fontSize: 16, color: Colors.white70, letterSpacing: 2)),
              const SizedBox(height: 8),
              Container(height: 1, width: 120, color: Colors.white30),
              const SizedBox(height: 8),
              const Text('Victoria University — Group 7', style: TextStyle(fontSize: 12, color: Colors.white54)),
              const SizedBox(height: 60),
              const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 2.5)),
              const SizedBox(height: 16),
              const Text('Loading...', style: TextStyle(color: Colors.white54, fontSize: 13)),
            ]),
          ),
        ),
      ),
    );
  }
}
