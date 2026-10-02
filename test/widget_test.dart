import 'package:flutter_test/flutter_test.dart';
import 'package:login_app/main.dart';

void main() {
  testWidgets('Login screen shows main elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create New Account'), findsOneWidget);
  });
}
