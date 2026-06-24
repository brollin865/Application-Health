import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiService.post('login', {'email': email, 'password': password}, auth: false);
    await ApiService.saveToken(res['token']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', res['user']['role']);
    await prefs.setInt('user_id', res['user']['id']);
    await prefs.setString('user_name', res['user']['name']);
    await prefs.setString('user_email', res['user']['email']);
    return res;
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    final res = await ApiService.post('register', {
      'name': name, 'email': email,
      'password': password, 'password_confirmation': password, 'role': role,
    }, auth: false);
    await ApiService.saveToken(res['token']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', res['user']['role']);
    await prefs.setInt('user_id', res['user']['id']);
    await prefs.setString('user_name', res['user']['name']);
    await prefs.setString('user_email', res['user']['email']);
    return res;
  }

  static Future<void> logout() async {
    try { await ApiService.post('logout', {}); } catch (_) {}
    await ApiService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null && token.isNotEmpty;
  }
}
