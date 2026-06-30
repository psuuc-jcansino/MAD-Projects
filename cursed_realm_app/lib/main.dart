import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/save_service.dart';
import 'core/services/audio_service.dart';
import 'ui/screens/main_menu_screen.dart';
import 'ui/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize save system
  await SaveService.init();
  await AudioService.instance.init();

  runApp(
    const ProviderScope(
      child: CursedRealmApp(),
    ),
  );
}

class CursedRealmApp extends StatelessWidget {
  const CursedRealmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cursed Realm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkGothic,
      home: const MainMenuScreen(),
    );
  }
}
