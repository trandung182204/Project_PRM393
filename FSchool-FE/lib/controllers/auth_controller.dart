import 'package:bai1/models/auth_response.dart';
import 'package:bai1/models/login_request.dart';
import 'package:bai1/models/reset_password_request.dart';
import 'package:bai1/services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<AuthResponse> login(String phone, String password) async {
    final request = LoginRequest(phone: phone, password: password);

    return await _authService.login(request);
  }

  Future<bool> sendOtp(String phoneNumber) async {
    return await _authService.sendOtp(phoneNumber);
  }

  Future<bool> resetPassword(ResetPasswordRequest request) async {
    return await _authService.resetPassword(request);
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
