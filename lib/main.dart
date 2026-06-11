import 'package:flutter/material.dart';
import 'package:health_ai_application/services/api_config.dart';
import 'package:health_ai_application/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.init();
  runApp(const HealthAiApp());
}
