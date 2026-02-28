// Basic smoke test for Helpi Student app.

import 'package:flutter_test/flutter_test.dart';

import 'package:helpi_student/app/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const HelpiStudentApp());
    await tester.pumpAndSettle();
  });
}
