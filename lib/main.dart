import 'package:flutter/material.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/patient/patient_dashboard.dart';
import 'screens/patient/symptom_checker_screen.dart';
import 'screens/patient/consultation_screen.dart';
import 'screens/patient/profile_screen.dart';
import 'screens/patient/diagnosis_history_screen.dart';
import 'screens/doctor/doctor_dashboard.dart';
import 'screens/doctor/doctor_consultation_screen.dart';
import 'screens/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HealthMonitorApp());
}

class HealthMonitorApp extends StatelessWidget {
  const HealthMonitorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Monitor - VU Group 7',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F4E79), primary: const Color(0xFF1F4E79), secondary: const Color(0xFF2E75B6)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1F4E79), foregroundColor: Colors.white, elevation: 0),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F4E79), foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true, fillColor: Colors.grey[50],
        ),
      ),
      initialRoute: '/',
      routes: {
        '/':                  (_) => const SplashScreen(),
        '/login':             (_) => const LoginScreen(),
        '/register':          (_) => const RegisterScreen(),
        '/patient':           (_) => const PatientDashboard(),
        '/symptom-checker':   (_) => const SymptomCheckerScreen(),
        '/consultations':     (_) => const ConsultationScreen(),
        '/profile':           (_) => const ProfileScreen(),
        '/diagnosis-history': (_) => const DiagnosisHistoryScreen(),
        '/doctor':            (_) => const DoctorDashboard(),
        '/doctor/consults':   (_) => const DoctorConsultationScreen(),
        '/admin':             (_) => const AdminDashboard(),
      },
    );
  }
}
