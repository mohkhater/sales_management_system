import 'package:flutter_test/flutter_test.dart';

import 'package:sales_management_system/main.dart';

void main() {
  testWidgets('Sales Management System loads', (tester) async {
    await tester.pumpWidget(const SalesManagementApp());

    expect(find.text('المنتجات'), findsOneWidget);
  });
}