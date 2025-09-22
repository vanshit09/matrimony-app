// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:matrimony_app/src/app.dart';
import 'package:provider/provider.dart';
import 'package:matrimony_app/src/providers/auth_provider.dart';
import 'package:matrimony_app/src/providers/profile_provider.dart';
import 'package:matrimony_app/src/providers/chat_provider.dart';

void main() {
  testWidgets('Matrimony app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: const MatrimonyApp(),
      ),
    );

    // Verify that the app loads
    expect(find.text('Matrimony'), findsOneWidget);
  });
}
