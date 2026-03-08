import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:bizly/main.dart';

void main() {
  testWidgets('MyApp boots with GetMaterialApp config', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final getApp = tester.widget<GetMaterialApp>(find.byType(GetMaterialApp));
    expect(getApp.title, 'Bizly');
    expect(getApp.debugShowCheckedModeBanner, isFalse);
  });
}
