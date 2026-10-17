import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/expense.dart';
import 'auth_service.dart';
import 'session_handler.dart';

class ExpenseService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  Map<String, String> _buildHeaders(String token, {bool jsonContent = false}) {
    return {
      'Accept': 'application/json',
      if (jsonContent) 'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Expense>> getExpenses() async {
    final token = await _authService.getToken();
    if (token == null) {
      await SessionHandler.handleUnauthorized();
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/expenses'),
        headers: _buildHeaders(token),
      );

      debugPrint('getExpenses response [${response.statusCode}]');

      if (response.statusCode == 401) {
        await SessionHandler.handleUnauthorized();
        return [];
      }
      if (response.statusCode == 403) {
        SessionHandler.showForbidden();
        return [];
      }

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Expense.fromJson(e)).toList();
      }
      debugPrint('getExpenses unexpected status: [${response.statusCode}] ${response.body}');
      return [];
    } catch (e) {
      debugPrint('getExpenses error: $e');
      return [];
    }
  }

  Future<bool> addExpense(String title, String amount, String date, String category) async {
    final token = await _authService.getToken();
    if (token == null) {
      await SessionHandler.handleUnauthorized();
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/expenses'),
        headers: _buildHeaders(token, jsonContent: true),
        body: jsonEncode({
          'title': title,
          'amount': amount,
          'expense_date': date,
          'category': category,
        }),
      );

      debugPrint('addExpense response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 401) {
        await SessionHandler.handleUnauthorized();
        return false;
      }
      if (response.statusCode == 403) {
        SessionHandler.showForbidden();
        return false;
      }

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error creating expense: $e');
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    final token = await _authService.getToken();
    if (token == null) {
      await SessionHandler.handleUnauthorized();
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/expenses/$id'),
        headers: _buildHeaders(token),
      );

      debugPrint('deleteExpense response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 401) {
        await SessionHandler.handleUnauthorized();
        return false;
      }
      if (response.statusCode == 403) {
        SessionHandler.showForbidden();
        return false;
      }

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      return false;
    }
  }

  Future<bool> updateExpense(int id, String title, String amount, String date, String category) async {
    final token = await _authService.getToken();
    if (token == null) {
      await SessionHandler.handleUnauthorized();
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/expenses/$id'),
        headers: _buildHeaders(token, jsonContent: true),
        body: jsonEncode({
          'title': title,
          'amount': amount,
          'expense_date': date,
          'category': category,
        }),
      );

      debugPrint('updateExpense response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 401) {
        await SessionHandler.handleUnauthorized();
        return false;
      }
      if (response.statusCode == 403) {
        SessionHandler.showForbidden();
        return false;
      }

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating expense: $e');
      return false;
    }
  }
}