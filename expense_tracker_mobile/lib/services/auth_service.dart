import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  final String baseUrl = ApiConfig.baseUrl;

  /// Holds the last error message for UI display
  String? lastErrorMessage;

  // ==========================================
  // TOKEN MANAGEMENT
  // ==========================================

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ==========================================
  // AUTHENTICATION METHODS
  // ==========================================

  /// Log in an existing user.
  /// Returns null on success, or a user-friendly error message on failure.
  Future<String?> login(String email, String password) async {
    lastErrorMessage = null;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Accept': 'application/json'},
        body: {
          'email': email,
          'password': password,
          'device_name': 'flutter-mobile',
        },
      );

      debugPrint('AuthService.login response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token == null) {
          lastErrorMessage = 'Authentication failed: Server did not return a token.';
          return lastErrorMessage;
        }
        await saveToken(token.toString());
        return null;
      } else if (response.statusCode == 422) {
        lastErrorMessage = _extractErrorMessage(
          response.body,
          defaultMessage: 'Invalid email or password. Please try again.',
        );
        return lastErrorMessage;
      } else if (response.statusCode >= 500) {
        lastErrorMessage = 'Server error (${response.statusCode}). Please try again later.';
        return lastErrorMessage;
      } else {
        lastErrorMessage = _extractErrorMessage(
          response.body,
          defaultMessage: 'Login failed (status ${response.statusCode}).',
        );
        return lastErrorMessage;
      }
    } catch (e) {
      debugPrint('AuthService.login exception: $e');
      lastErrorMessage = 'Unable to connect to server. Check your network or CORS settings.';
      return lastErrorMessage;
    }
  }

  /// Register a new user.
  /// Returns null on success, or a user-friendly error message on failure.
  Future<String?> register(String name, String email, String password) async {
    lastErrorMessage = null;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Accept': 'application/json'},
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'device_name': 'flutter-mobile',
        },
      );

      debugPrint('AuthService.register response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        if (token == null) {
          lastErrorMessage = 'Registration failed: Server did not return a token.';
          return lastErrorMessage;
        }
        await saveToken(token.toString());
        return null;
      } else if (response.statusCode == 422) {
        lastErrorMessage = _extractErrorMessage(
          response.body,
          defaultMessage: 'Validation failed. Please check your input.',
        );
        return lastErrorMessage;
      } else if (response.statusCode >= 500) {
        lastErrorMessage = 'Server error (${response.statusCode}). Please try again later.';
        return lastErrorMessage;
      } else {
        lastErrorMessage = _extractErrorMessage(
          response.body,
          defaultMessage: 'Registration failed (status ${response.statusCode}).',
        );
        return lastErrorMessage;
      }
    } catch (e) {
      debugPrint('AuthService.register exception: $e');
      lastErrorMessage = 'Unable to connect to server. Check your network or CORS settings.';
      return lastErrorMessage;
    }
  }

  /// Logout the user
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        debugPrint('AuthService.logout response [${response.statusCode}]');
      } catch (e) {
        debugPrint('Logout API error: $e');
      }
    }
    // Always clear the token locally, even if the backend call fails
    await removeToken(); 
  }

  String _extractErrorMessage(String responseBody, {required String defaultMessage}) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        if (decoded['errors'] is Map) {
          final errorsMap = decoded['errors'] as Map;
          if (errorsMap['email'] is List && (errorsMap['email'] as List).isNotEmpty) {
            return (errorsMap['email'] as List).first.toString();
          }
          final errorList = <String>[];
          for (final value in errorsMap.values) {
            if (value is List) {
              errorList.addAll(value.map((e) => e.toString()));
            } else if (value is String) {
              errorList.add(value);
            }
          }
          if (errorList.isNotEmpty) {
            return errorList.join('\n');
          }
        }
        if (decoded['message'] != null && decoded['message'].toString().trim().isNotEmpty) {
          return decoded['message'].toString();
        }
      }
    } catch (_) {}
    return defaultMessage;
  }
}