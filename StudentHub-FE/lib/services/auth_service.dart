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
      // Đọc lỗi từ ExceptionMiddleware của .NET trả về
      final error = jsonDecode(response.body);
      throw Exception(error['Message'] ?? "Gửi mã thất bại.");
    }
  }

  // 2. Reset mật khẩu
  Future<bool> resetPassword(ResetPasswordRequest request) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password/reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      // Sẽ tóm được dòng: "Mã OTP đã hết hạn hoặc không tồn tại."
      final error = jsonDecode(response.body);
      throw Exception(error['Message'] ?? "Đổi mật khẩu thất bại.");
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
