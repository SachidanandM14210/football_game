import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';

void main() {
  testWidgets('RondoApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RondoApp());
    expect(find.byType(RondoApp), findsOneWidget);
  });
}
