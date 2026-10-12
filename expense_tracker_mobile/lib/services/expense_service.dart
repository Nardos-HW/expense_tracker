import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.dart';
import 'auth_service.dart';

class ExpenseService {
  final String baseUrl = 'http://10.0.2.2:8000/api';
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
}