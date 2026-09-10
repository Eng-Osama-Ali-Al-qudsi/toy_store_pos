import 'package:flutter_test/flutter_test.dart';
import 'package:toy_store_pos/app.dart';

void main() {
  testWidgets('ToyStoreApp starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ToyStoreApp());

    expect(find.byType(ToyStoreApp), findsOneWidget);
  });
}