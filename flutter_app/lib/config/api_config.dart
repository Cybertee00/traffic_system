import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../pages/settings_backend.dart';

class ApiConfig {
  // Helper method to get base URL from settings
  static String getBaseUrl(BuildContext context) {
    final settings = Provider.of<SettingsBackend>(context, listen: false);
    return settings.baseUrl;
  }
  
  // Helper method to build full URLs
  static String buildUrl(BuildContext context, String endpoint) {
    final baseUrl = getBaseUrl(context);
    // Remove leading slash if present to avoid double slashes
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$baseUrl/$cleanEndpoint';
  }
  
  // Legacy static method for backward compatibility (uses Render server)
  static const String defaultBaseUrl = 'https://smart-license-api-9otw.onrender.com';
  
  static String buildUrlLegacy(String endpoint) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$defaultBaseUrl/$cleanEndpoint';
  }
}
