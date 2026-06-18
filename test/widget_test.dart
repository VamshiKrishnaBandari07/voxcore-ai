import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voicecode/core/database/database_init.dart';
import 'package:voicecode/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDatabaseFactory();
  });

  testWidgets('VoiceCode app loads home screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: VoiceCodeApp()),
    );
    await tester.pump();

    expect(find.text('VoiceCode'), findsOneWidget);
    expect(find.text('Start Session'), findsOneWidget);
  });
}
