import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.smart-system.com'; // Replace with actual API URL
  
  // Authentication
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Dashboard Statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch dashboard stats');
      }
    } catch (e) {
      // Return mock data for demo
      return {
        'totalUsers': 1247,
        'admins': 12,
        'instructors': 89,
        'learners': 1146,
        'testingStations': 45,
        'activeStations': 42,
        'inactiveStations': 3,
        'totalReports': 8934,
        'reportsThisMonth': 1234,
        'reportsLastMonth': 987,
        'passedTests': 6968,
        'failedTests': 1966,
        'passRate': 78.0,
        'provinceStats': [
          {'name': 'Gauteng', 'reports': 2340},
          {'name': 'KZN', 'reports': 1890},
          {'name': 'Western Cape', 'reports': 1560},
          {'name': 'Eastern Cape', 'reports': 1230},
          {'name': 'Free State', 'reports': 890},
          {'name': 'Others', 'reports': 1014},
        ],
      };
    }
  }

  // Instructor Management
  static Future<List<Map<String, dynamic>>> getInstructors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/instructors'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch instructors');
      }
    } catch (e) {
      // Return mock data for demo
      return [
        {
          'id': '1',
          'name': 'John',
          'surname': 'Doe',
          'idNumber': '8501015009087',
          'contactNumber': '+27123456789',
          'infrNumber': 'INF001',
          'status': 'Active',
          'registrationDate': '2024-01-15',
        },
        {
          'id': '2',
          'name': 'Jane',
          'surname': 'Smith',
          'idNumber': '9203155009087',
          'contactNumber': '+27123456790',
          'infrNumber': 'INF002',
          'status': 'Active',
          'registrationDate': '2024-01-20',
        },
        {
          'id': '3',
          'name': 'Mike',
          'surname': 'Johnson',
          'idNumber': '8807125009087',
          'contactNumber': '+27123456791',
          'infrNumber': 'INF003',
          'status': 'Inactive',
          'registrationDate': '2024-02-01',
        },
      ];
    }
  }

  static Future<bool> registerInstructor(Map<String, dynamic> instructorData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/instructors'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(instructorData),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateInstructor(String id, Map<String, dynamic> instructorData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/instructors/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(instructorData),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> toggleInstructorStatus(String id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/instructors/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Validation
  static bool validateSouthAfricanID(String id) {
    if (id.length != 13) return false;
    
    // Check if all characters are digits
    if (!RegExp(r'^\d{13}$').hasMatch(id)) return false;
    
    // Validate date part (YYMMDD)
    final year = int.parse(id.substring(0, 2));
    final month = int.parse(id.substring(2, 4));
    final day = int.parse(id.substring(4, 6));
    
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    
    return true;
  }

  static bool validateSouthAfricanPhone(String phone) {
    // Remove spaces and dashes
    final cleanPhone = phone.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check if it starts with +27 or 0
    if (cleanPhone.startsWith('+27')) {
      return cleanPhone.length == 12;
    } else if (cleanPhone.startsWith('0')) {
      return cleanPhone.length == 10;
    }
    
    return false;
  }
} 