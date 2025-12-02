/// API Configuration for Smart Admin App
/// Centralized configuration for all API endpoints
class ApiConfig {
  // Render server URL - update this with your actual Render service URL
  // Get it from: Render Dashboard → Your Service → URL
  static const String baseUrl = 'https://smart-license-api-9otw.onrender.com';
  
  // Helper method to build full URLs
  static String buildUrl(String endpoint) {
    // Remove leading slash if present to avoid double slashes
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$baseUrl/$cleanEndpoint';
  }
}

