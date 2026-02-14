import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders FairyCraft label', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('FairyCraft')),
      ),
    );

    expect(find.text('FairyCraft'), findsOneWidget);
  });
}
