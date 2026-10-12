class Expense {
  final int id;
  final String title;
  final String amount;
  final String expenseDate;
  final String? category;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.expenseDate,
    this.category,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toString(),
      expenseDate: json['expense_date'],
      category: json['category'],
    );
  }
}