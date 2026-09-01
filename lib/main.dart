import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MockMateApp());
}

class MockMateApp extends StatelessWidget {
  const MockMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,

      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF1E3C72),
        scaffoldBackgroundColor: Colors.white,
        cardTheme: const CardThemeData(
          elevation: 6,
          margin: EdgeInsets.all(12),
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardThemeData(
          elevation: 6,
          margin: EdgeInsets.all(12),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}