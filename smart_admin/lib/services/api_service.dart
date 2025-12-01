import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000'; // Local API URL
  
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
      } else if (response.statusCode == 500) {
        // Handle FastAPI 500 error as authentication failure
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['detail'] ?? 'Invalid credentials');
        } catch (e) {
          throw Exception('Invalid credentials');
        }
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
      final response = await http.put(
        Uri.parse('$baseUrl/instructors/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Instructor Registration Methods
  static Future<int> getNextUserId() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/id/last'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['last_id'] ?? 0) + 1;
      }
      return 1; // Default to 1 if no users exist
    } catch (e) {
      print('Error getting next user ID: $e');
      return 1;
    }
  }

  static Future<bool> validateStation(int stationId) async {
    try {
      print('Validating station ID: $stationId');
      final response = await http.get(
        Uri.parse('$baseUrl/stations/$stationId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Station validation response status: ${response.statusCode}');
      print('Station validation response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error validating station: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> createUser({
    required String username,
    required String password,
    required String email,
    required String role,
    required bool isActive,
  }) async {
    try {
      print('Creating user with data:');
      print('username: $username');
      print('email: $email');
      print('role: $role');
      print('is_active: $isActive');
      
      final requestBody = {
        'username': username,
        'password': password,
        'email': email,
        'role': role,
        'is_active': isActive,
      };
      
      print('Request body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/users/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('Created user data: $data');
        print('User ID: ${data['id']}');
        return {'success': true, 'data': data, 'user_id': data['id']};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['detail'] ?? 'Failed to create user'};
      }
    } catch (e) {
      print('Error creating user: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createInstructorProfile({
    required int userId,
    required String infNr,
    required int stationId,
  }) async {
    try {
      print('Creating instructor profile with data:');
      print('user_id: $userId');
      print('inf_nr: $infNr');
      print('station_id: $stationId');
      
      final requestBody = {
        'user_id': userId,
        'inf_nr': infNr,
        'station_id': stationId,
      };
      
      print('Request body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/instructor-profiles/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['detail'] ?? 'Failed to create instructor profile'};
      }
    } catch (e) {
      print('Error creating instructor profile: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createUserProfile({
    required int userId,
    required String name,
    required String surname,
    required String dateOfBirth,
    required String gender,
    required String nationality,
    required String idNumber,
    required String contactNumber,
    required String physicalAddress,
    required String race,
  }) async {
    try {
      print('Creating user profile with data:');
      print('user_id: $userId');
      print('name: $name');
      print('surname: $surname');
      print('date_of_birth: $dateOfBirth');
      print('gender: $gender');
      print('nationality: $nationality');
      print('id_number: $idNumber');
      print('contact_number: $contactNumber');
      print('physical_address: $physicalAddress');
      print('race: $race');
      
      final requestBody = {
        'user_id': userId,
        'name': name,
        'surname': surname,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'nationality': nationality,
        'id_number': idNumber,
        'contact_number': contactNumber,
        'physical_address': physicalAddress,
        'race': race,
      };
      
      print('Request body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/user-profiles/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['detail'] ?? 'Failed to create user profile'};
      }
    } catch (e) {
      print('Error creating user profile: $e');
      return {'success': false, 'message': 'Network error: $e'};
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