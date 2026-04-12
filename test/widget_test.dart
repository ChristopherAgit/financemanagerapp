import 'package:flutter_test/flutter_test.dart';
import 'package:financemanagerapp/main.dart';

void main() {
  testWidgets('Dashboard smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceManagerApp());
    expect(find.text('FinanceManager'), findsOneWidget);
  });
}