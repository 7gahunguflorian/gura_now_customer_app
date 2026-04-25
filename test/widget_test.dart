import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gura_now_customer_app/core/di/injection_container.dart' as di;
import 'package:gura_now_customer_app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const ch = MethodChannel('plugins.it_abs.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ch, (call) async {
      if (call.method == 'readAll') return <String, String>{};
      return null;
    });
    SharedPreferences.setMockInitialValues({});
    await di.init();
  });

  testWidgets('App smoke test', (tester) async {
    await tester.pumpWidget(const GuraNowApp());
    await tester.pump();
    expect(find.byType(GuraNowApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
