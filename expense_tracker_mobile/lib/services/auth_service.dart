import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // 10.0.2.2 points the Android emulator to your computer's localhost:8000
  final String baseUrl = 'http://10.0.2.2:8000/api';
  final storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Securely save the Sanctum token to the mobile device
        await storage.write(key: 'auth_token', value: data['token']);
        return true;
      }
    } catch (e) {
      print("Connection error: $e");
    }
    return false;
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      // Delete token from device storage
      await storage.delete(key: 'auth_token');
    }
  }
}