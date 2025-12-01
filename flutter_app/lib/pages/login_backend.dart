import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'package:provider/provider.dart';
import 'session_backend.dart';
import '../config/api_config.dart';

class LoginController {
  static Future<void> login(
    BuildContext context,
    String username,
    String password,
  ) async {
    username = username.trim();
    password = password.trim();
    const role = "instructor"; // Default role

    if (username.isEmpty || password.isEmpty) {
      showError(context, "Please enter both username and password");
      return;
    }

    // SettingsBackend now always has an IP (default or loaded)
    // No need to wait for loading since default IP is set immediately
    final url = Uri.parse(ApiConfig.buildUrl(context, "login"));

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
          "role": role, // Use default
        }),
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        final int userId = (decoded is Map && decoded['userid'] != null)
            ? decoded['userid'] as int
            : -1;
        final Map<String, int> userDetails = {'userid': userId};
        print('userid: ${userDetails['userid']}');

        // Update session with basic login info
        final session = Provider.of<SessionBackend>(context, listen: false);
        session.updateFromLogin(
          userId: userId,
          username: decoded is Map ? decoded['username'] as String? : null,
          email: decoded is Map ? decoded['email'] as String? : null,
          role: decoded is Map ? decoded['role'] as String? : null,
        );

        // Fetch and print user profile using the userId
        if (userId > 0) {
          final Uri profileUrl = Uri.parse(ApiConfig.buildUrl(context, 'user-profiles/$userId'));
          try {
            final http.Response profileResp = await http.get(
              profileUrl,
              headers: {
                'Content-Type': 'application/json',
              },
            );
            if (profileResp.statusCode == 200) {
              print('user profile ($userId): ${profileResp.body}');
              try {
                final Map<String, dynamic> profile = jsonDecode(profileResp.body) as Map<String, dynamic>;
                session.updateFromProfile(profile);
              } catch (e) {
                // If decoding fails, still proceed
                print('Failed to decode user profile JSON: $e');
              }
            } else {
              print('Failed to fetch user profile ($userId): ${profileResp.statusCode} ${profileResp.body}');
            }
          } catch (e) {
            print('Error fetching user profile ($userId): $e');
          }
        } else {
          print('Invalid userId from login response; skipping profile fetch.');
        }

        // Success: Navigate to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      } else {
        final errorMessage =
            jsonDecode(response.body)['detail'] ?? 'Login failed';
        showError(context, errorMessage);
      }
    } catch (e) {
      showError(context, "Could not connect to server");
    }
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
