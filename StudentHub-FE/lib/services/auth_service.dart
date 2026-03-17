import 'dart:convert';

import 'package:bai1/config/api_config.dart';
import 'package:bai1/models/auth_response.dart';
import 'package:bai1/models/change_password_request.dart';
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
      String message = "Login failed";
      try {
        if (response.body.isNotEmpty) {
          final error = jsonDecode(response.body);
          message = error['Message'] ?? message;
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  Future<bool> changePassword(ChangePasswordRequest request, String token) async {
    final response = await http.post(
      Uri.parse(ApiConfig.changePassword),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      String message = "Đổi mật khẩu thất bại.";
      try {
        if (response.body.isNotEmpty) {
          final error = jsonDecode(response.body);
          message = error['Message'] ?? message;
        } else {
          message = "Lỗi từ server (${response.statusCode})";
        }
      } catch (e) {
        message = "Lỗi hệ thống: ${response.statusCode}";
      }
      throw Exception(message);
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
      String message = "Gửi mã thất bại.";
      try {
        if (response.body.isNotEmpty) {
          final error = jsonDecode(response.body);
          message = error['Message'] ?? message;
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  Future<bool> resetPassword(ResetPasswordRequest request) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password/reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      String message = "Đổi mật khẩu thất bại.";
      try {
        if (response.body.isNotEmpty) {
          final error = jsonDecode(response.body);
          message = error['Message'] ?? message;
        }
      } catch (_) {}
      throw Exception(message);
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
