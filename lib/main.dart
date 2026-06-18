import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/database_init.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabaseFactory();
  runApp(const ProviderScope(child: VoiceCodeApp()));
}
/// Root application widget. Theme and navigation live here; feature UI is delegated.
class VoiceCodeApp extends StatelessWidget {
  const VoiceCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoiceCode',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
