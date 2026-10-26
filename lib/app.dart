import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/common/splash_screen.dart';

class SiMelayurApp extends StatelessWidget {
  const SiMelayurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SI-MELAYUR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}
