import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.dart';
import 'auth_service.dart';

class ExpenseService {
  final String baseUrl = 'http://127.0.0.1:8000/api';
  final AuthService _authService = AuthService();

  Future<List<Expense>> getExpenses() async {
    final token = await _authService.getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/expenses'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Expense.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> addExpense(String title, String amount, String date, String category) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/expenses'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'amount': amount,
          'expense_date': date,
          'category': category,
        }),
      );

      // Laravel returns 201 (Created) or 200 (OK) on successful creation
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Error creating expense: $e");
      return false;
    }
  }

  // DELETE request to remove an expense
  Future<bool> deleteExpense(int id) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/expenses/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      // Laravel typically returns 200 or 204 on successful deletion
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error deleting expense: $e");
      return false;
    }
  }

  // PUT request to update an existing expense
  Future<bool> updateExpense(int id, String title, String amount, String date, String category) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/expenses/$id'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'amount': amount,
          'expense_date': date,
          'category': category,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updating expense: $e");
      return false;
    }
  }
}