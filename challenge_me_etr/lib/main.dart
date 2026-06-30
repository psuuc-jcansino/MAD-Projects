import 'package:challenge_me_etr/screens/main_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ChallengeMeApp());
}

class ChallengeMeApp extends StatelessWidget {
  const ChallengeMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainScreen());
  }
}
