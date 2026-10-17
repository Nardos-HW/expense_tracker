import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_mobile/main.dart';

void main() {
  testWidgets('App smoke test: loads LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());

    expect(find.text('ExpenseTracker'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
