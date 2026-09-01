import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate_ai/main.dart';

void main() {
  testWidgets('MockMate AI app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MockMateApp());

    expect(find.byType(MockMateApp), findsOneWidget);
  });
}