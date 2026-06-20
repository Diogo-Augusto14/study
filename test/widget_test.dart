import 'package:flutter_test/flutter_test.dart';

import 'package:study/main.dart';

void main() {
  testWidgets('shows the StudyMatch discovery screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudySwipeApp());
    await tester.pumpAndSettle();

    expect(find.text('StudyMatch'), findsOneWidget);
    expect(find.text('Flutter do zero'), findsOneWidget);
  });
}
