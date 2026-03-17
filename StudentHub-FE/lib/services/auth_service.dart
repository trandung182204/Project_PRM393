import 'dart:convert';

import 'package:bai1/config/api_config.dart';
import 'package:bai1/models/auth_response.dart';
import 'package:bai1/models/login_request.dart';
import 'package:bai1/models/reset_password_request.dart';

import 'package:http/http.dart' as http;

class AuthService {
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } else {
      throw Exception("Login failed");
    }
  }

  Future<bool> sendOtp(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      // Read error from .NET ExceptionMiddleware
      final error = jsonDecode(response.body);
      throw Exception(error['Message'] ?? "Failed to send code.");
    }
  }

  // 2. Reset password
  Future<bool> resetPassword(ResetPasswordRequest request) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password/reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      // Catch message like: "OTP code expired or does not exist."
      final error = jsonDecode(response.body);
      throw Exception(error['Message'] ?? "Password reset failed.");
    }
  }

  Future<void> logout() async {
    final response = await http.post(
      Uri.parse(ApiConfig.logout),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      print("Logout API call failed");
    }
    return;
  }
}
