import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musikr/app/app.dart';

void main() {
  testWidgets('App smoke test — launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MusiKRApp()));
    expect(find.text('MusiKR'), findsAny);
  });
}
