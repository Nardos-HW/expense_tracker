import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ExpenseService _expenseService = ExpenseService();
  late Future<List<Expense>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _expensesFuture = _expenseService.getExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FD),
      appBar: AppBar(
        title: const Text('My Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF132E50),
        elevation: 0,
      ),
      body: FutureBuilder<List<Expense>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1677E8)));
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No expenses found.', style: TextStyle(color: Color(0xFF647894))));
          }

          final expenses = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return Card(
                color: Colors.white,
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE1EAF6)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF0F7FF),
                    child: Icon(Icons.receipt_long, color: Color(0xFF1677E8)),
                  ),
                  title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF132E50))),
                  subtitle: Text('${expense.category ?? 'Uncategorized'} • ${expense.expenseDate}'),
                  trailing: Text('\$${expense.amount}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1677E8))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}