import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBackend extends ChangeNotifier {
  static const String _serverUrlKey = 'server_url';
  // Default to Render server (HTTPS)
  static const String _defaultUrl = 'https://smart-license-api-9otw.onrender.com';
  // Legacy IP for backward compatibility
  static const String _defaultIp = '172.16.24.23';
  
  String _serverUrl = _defaultUrl;
  bool _isLoading = false;
  
  String get serverUrl => _serverUrl;
  String get ipAddress => _extractIpFromUrl(_serverUrl); // For backward compatibility
  bool get isLoading => _isLoading;
  
  SettingsBackend() {
    // Initialize with default URL immediately (synchronous)
    _serverUrl = _defaultUrl;
    _isLoading = false;
    
    // Load saved URL asynchronously in background
    _loadServerUrl();
  }
  
  Future<void> _loadServerUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(_serverUrlKey);
      if (savedUrl != null && savedUrl != _serverUrl) {
        _serverUrl = savedUrl;
        notifyListeners();
      } else {
        // Check for legacy IP address format
        final savedIp = prefs.getString('server_ip_address');
        if (savedIp != null && _isValidIpAddress(savedIp)) {
          // Migrate from IP to URL format
          _serverUrl = 'http://$savedIp:8000';
          await prefs.setString(_serverUrlKey, _serverUrl);
          await prefs.remove('server_ip_address');
          notifyListeners();
        }
      }
    } catch (e) {
      // Keep default URL if loading fails
    }
  }
  
  Future<void> setServerUrl(String url) async {
    if (url == _serverUrl) return;
    
    // Validate URL format
    if (!_isValidUrl(url) && !_isValidIpAddress(url)) {
      throw ArgumentError('Invalid URL or IP address format');
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      // If it's just an IP, convert to full URL
      String fullUrl = url;
      if (_isValidIpAddress(url) && !url.startsWith('http')) {
        fullUrl = 'http://$url:8000';
      } else if (!url.startsWith('http://') && !url.startsWith('https://')) {
        fullUrl = 'https://$url';
      }
      
      await prefs.setString(_serverUrlKey, fullUrl);
      _serverUrl = fullUrl;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to save server URL: $e');
    }
  }
  
  // Legacy method for backward compatibility
  Future<void> setIpAddress(String ip) async {
    await setServerUrl(ip);
  }
  
  Future<void> resetToDefault() async {
    await setServerUrl(_defaultUrl);
  }
  
  bool _isValidUrl(String url) {
    // Check if it's a valid URL (http/https) or domain
    final urlRegex = RegExp(
      r'^https?://([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}(/.*)?$'
    );
    final domainRegex = RegExp(
      r'^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}(/.*)?$'
    );
    return urlRegex.hasMatch(url) || domainRegex.hasMatch(url);
  }
  
  bool _isValidIpAddress(String ip) {
    // Basic IP validation regex
    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    );
    return ipRegex.hasMatch(ip);
  }
  
  String _extractIpFromUrl(String url) {
    // Extract IP from URL for backward compatibility
    if (_isValidIpAddress(url)) return url;
    final match = RegExp(r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})').firstMatch(url);
    return match?.group(1) ?? _defaultIp;
  }
  
  // Get base URL for API (no port needed for Render)
  String get baseUrl {
    // Remove port if it's a Render URL (HTTPS doesn't need :8000)
    if (_serverUrl.contains('onrender.com')) {
      return _serverUrl.replaceAll(':8000', '');
    }
    // For IP addresses, add port
    if (_serverUrl.startsWith('http://') && !_serverUrl.contains(':8000')) {
      return '$_serverUrl:8000';
    }
    return _serverUrl;
  }
  
  // Get WebSocket URI for April Tag Bridge
  String getWebSocketUri(int port) {
    final base = _serverUrl.replaceAll('https://', 'wss://').replaceAll('http://', 'ws://');
    if (base.contains('onrender.com')) {
      // Render doesn't support WebSocket, return localhost fallback
      return 'ws://localhost:$port';
    }
    return base.replaceAll(RegExp(r':\d+$'), ':$port');
  }
}

