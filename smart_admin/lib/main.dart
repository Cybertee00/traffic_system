import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_admin/screens/login_screen.dart';
import 'package:smart_admin/utils/app_theme.dart';
import 'package:smart_admin/services/navigation_service.dart';
import 'package:smart_admin/services/session_service.dart';

void main() {
  runApp(const SmartApp());
}

class SmartApp extends StatelessWidget {
  const SmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SessionService(),
      child: MaterialApp(
        title: 'SMART - System for Motorists Automated Road Testing',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        onGenerateRoute: NavigationService.generateRoute,
        home: const LoginScreen(),
      ),
    );
  }
}
