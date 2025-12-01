import 'package:flutter/material.dart';
import 'package:smart_admin/screens/login_screen.dart';
import 'package:smart_admin/screens/dashboard_screen.dart';
import 'package:smart_admin/screens/registration_screen.dart';
import 'package:smart_admin/screens/instructor_management_screen.dart';
import 'package:smart_admin/screens/learner_booking_screen.dart';
import 'package:smart_admin/screens/admin_registration_screen.dart';

class NavigationService {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case '/registration':
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());
      case '/instructor-management':
        return MaterialPageRoute(builder: (_) => const InstructorManagementScreen());
      case '/learner-booking':
        return MaterialPageRoute(builder: (_) => const LearnerBookingScreen());
      case '/admin-registration':
        return MaterialPageRoute(builder: (_) => const AdminRegistrationScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
} 