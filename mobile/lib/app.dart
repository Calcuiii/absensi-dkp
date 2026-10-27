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
      builder: (context, child) => Column(
        children: [
          const Material(
            color: Color(0xFFFFE6A6),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: Text(
                    'MODE DEMO • DATA CONTOH',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: child ?? const SizedBox.shrink()),
        ],
      ),
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}
