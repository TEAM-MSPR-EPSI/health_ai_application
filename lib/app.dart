import 'package:flutter/material.dart';
import 'package:health_ai_application/pages/main_navigation_page.dart';
import 'theme/app_theme.dart';

class HealthAiApp extends StatelessWidget {
  const HealthAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthAI Mobile',
      theme: AppTheme.lightTheme,
      home: const MainNavigationPage(),
    );
  }
}


