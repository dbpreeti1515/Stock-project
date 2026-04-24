import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project/injection_container.dart' as di;
import 'package:project/features/watchlist/presentation/widgets/stock_card.dart';
import 'package:project/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          return Directory.systemTemp.path;
        });
    await di.init();
  });

  testWidgets('renders watchlist and add stock entry point', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StockWatchApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Watchlist'), findsOneWidget);
    expect(find.text('Add Stock'), findsWidgets);
    expect(find.byType(StockCard), findsNWidgets(5));
    expect(find.text('AAPL'), findsOneWidget);
  });
}
