import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('admin label smoke', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('FairyCraft Admin')),
      ),
    );

    expect(find.text('FairyCraft Admin'), findsOneWidget);
  });
}
