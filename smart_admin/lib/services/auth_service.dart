
class AuthService {
  static bool _isAuthenticated = false;
  static String? _currentUser;
  static String? _userRole;

  static bool get isAuthenticated => _isAuthenticated;
  static String? get currentUser => _currentUser;
  static String? get userRole => _userRole;

  static Future<bool> login(String username, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Demo credentials - in real app, this would validate against backend
    if (username == 'admin' && password == 'admin123') {
      _isAuthenticated = true;
      _currentUser = username;
      _userRole = 'admin';
      return true;
    } else if (username == 'instructor' && password == 'instructor123') {
      _isAuthenticated = true;
      _currentUser = username;
      _userRole = 'instructor';
      return true;
    }
    
    return false;
  }

  static Future<bool> forgotPassword(String email) async {
    // Simulate password reset
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  static void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    _userRole = null;
  }

  static bool canRegisterInstructors() {
    return _userRole == 'admin';
  }

  static bool canManageInstructors() {
    return _userRole == 'admin';
  }
} 