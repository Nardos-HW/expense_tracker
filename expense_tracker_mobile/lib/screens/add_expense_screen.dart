import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  // Make expense an optional parameter
  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _selectedCategory = 'Food';
  final List<String> _categories = ['Food', 'Transport', 'Utilities', 'Entertainment', 'Other'];
  DateTime _selectedDate = DateTime.now();
  
  final ExpenseService _expenseService = ExpenseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If we are editing, pre-fill the controllers with the existing data
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount;
      _selectedCategory = _categories.contains(widget.expense!.category) 
          ? widget.expense!.category! 
          : 'Other';
      
      try {
        _selectedDate = DateTime.parse(widget.expense!.expenseDate);
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Format date as YYYY-MM-DD for Laravel
    final formattedDate = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    bool success;

    if (widget.expense == null) {
      // Create new
      success = await _expenseService.addExpense(
        _titleController.text,
        _amountController.text,
        formattedDate,
        _selectedCategory,
      );
    } else {
      // Update existing
      success = await _expenseService.updateExpense(
        widget.expense!.id,
        _titleController.text,
        _amountController.text,
        formattedDate,
        _selectedCategory,
      );
    }

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) Navigator.pop(context, true); // Return true to trigger dashboard refresh
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.expense == null ? 'Failed to add expense' : 'Failed to update expense')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FD),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF132E50),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (\$)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter an amount' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) setState(() => _selectedCategory = newValue);
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Colors.white,
                title: const Text('Date'),
                subtitle: Text("${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}"),
                trailing: const Icon(Icons.calendar_today, color: Color(0xFF1677E8)),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1677E8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _saveExpense,
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isEditing ? 'UPDATE EXPENSE' : 'SAVE EXPENSE', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}