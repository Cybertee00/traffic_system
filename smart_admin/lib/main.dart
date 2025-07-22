import 'package:flutter/material.dart';
import 'package:smart_admin/screens/login_screen.dart';
import 'package:smart_admin/screens/dashboard_screen.dart';
import 'package:smart_admin/screens/registration_screen.dart';
import 'package:smart_admin/screens/instructor_management_screen.dart';
import 'package:smart_admin/utils/app_theme.dart';
import 'package:smart_admin/services/auth_service.dart';
import 'package:smart_admin/services/navigation_service.dart';

void main() {
  runApp(const SmartApp());
}

class SmartApp extends StatelessWidget {
  const SmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMART - System for Motorists Automated Road Testing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      onGenerateRoute: NavigationService.generateRoute,
      home: const LoginScreen(),
    );
  }
}
