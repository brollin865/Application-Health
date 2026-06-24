import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // ── CHANGE THIS TO YOUR SERVER URL ──────────────────────
  //fstatic const String baseUrl = 'http://10.0.2.2.8000/api';
  static const String baseUrl = 'http://192.168.4.7:8000/api';
//For physical device: use your local IP e.g. 'http://192.168.13.14/api'
  // For production:      'https://your-domain.com/api'
  // ────────────────────────────────────────────────────────

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ── GET ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$path'),
      headers: await _headers(),
    );
    return _handle(response);
  }

  // ── POST ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  // ── PUT ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> put(
      String path, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  static Map<String, dynamic> _handle(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        data['message'] ?? 'Something went wrong. Please try again.',
        response.statusCode,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}
