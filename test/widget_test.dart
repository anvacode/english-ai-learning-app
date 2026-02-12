import 'package:flutter_test/flutter_test.dart';
import 'package:english_ai_app/main.dart';

void main() {
  group('English AI App', () {
    testWidgets('App should build without errors', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify the app built successfully by finding the MaterialApp
      expect(find.byType(MyApp), findsOneWidget);
    });
  });
}
