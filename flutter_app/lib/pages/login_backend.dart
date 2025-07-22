import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginController {
  static final usernameController = TextEditingController();
  static final passwordController = TextEditingController();

  static void dispose() {
    //usernameController.dispose();
    //passwordController.dispose();
  }

  static void login(BuildContext context) {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // Dummy authentication
    if (username == 'pauln' && password == '123456') {
      // Clear the form
      usernameController.clear();
      passwordController.clear();
      
      // Navigate to home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid credentials. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
