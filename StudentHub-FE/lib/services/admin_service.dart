import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AdminService {
  Future<Map<String, dynamic>> createAccount({
    required String phoneNumber,
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? rollNumber,
    String? employeeId,
    String? department,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/Admin/create-account'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': phoneNumber,
        'email': email,
        'password': password,
        'fullName': fullName,
        'role': role,
        'rollNumber': rollNumber,
        'employeeId': employeeId,
        'department': department,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error creating account');
    }
  }
}
