import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import 'add_expense_screen.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

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
    _refreshExpenses();
  }

  // Extracted to a helper method to easily refresh the list after edits/deletes
  void _refreshExpenses() {
    setState(() {
      _expensesFuture = _expenseService.getExpenses();
    });
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              final nav = Navigator.of(context);
              await AuthService().logout();
              if (!mounted) return;
              // Navigate back to Login and clear all previous routes
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1677E8),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
          
          if (result == true && mounted) _refreshExpenses();
        },
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
              
              // 1. Wrap the Card in a Dismissible for Swipe-to-Delete
              return Dismissible(
                key: Key(expense.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text("Delete this expense?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false), 
                            child: const Text("CANCEL")
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true), 
                            child: const Text("DELETE", style: TextStyle(color: Colors.red))
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) async {
                  final messenger = ScaffoldMessenger.of(context);
                  final success = await _expenseService.deleteExpense(expense.id);
                  if (!mounted) return;
                  if (success) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Expense deleted'))
                    );
                  } else {
                    _refreshExpenses();
                  }
                },
                child: Card(
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
                    title: Text(
                      expense.title, 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF132E50))
                    ),
                    subtitle: Text('${expense.category ?? 'Uncategorized'}\n${expense.expenseDate}'),
                    
                    // 2. Wrap trailing in a Row to include both Price and Edit Button
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${expense.amount}', 
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1677E8))
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF647894), size: 20),
                          onPressed: () async {
                            // Navigate to AddExpenseScreen and pass the expense object to edit
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddExpenseScreen(expense: expense),
                              ),
                            );
                            if (result == true && mounted) _refreshExpenses();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}