// lib/main.dart

import 'package:authentipass/app_builder/app.dart';
import 'package:authentipass/core/api/app_config.dart';
import 'package:flutter/material.dart';
import 'package:authentipass/dependency_injection.dart' as di; // Import alias
import 'package:country_codes/country_codes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Dependency Injection
  await di.init(); 
  
  await CountryCodes.init();

  await AppConfig.init(); // Detect device and set IP

  runApp(const AuthenticatorApp());
}