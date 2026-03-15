import '../services/admin_service.dart';

class AdminController {
  final AdminService _adminService = AdminService();

  Future<void> createAccount({
    required String phoneNumber,
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? rollNumber,
    String? employeeId,
    String? department,
  }) async {
    await _adminService.createAccount(
      phoneNumber: phoneNumber,
      email: email,
      password: password,
      fullName: fullName,
      role: role,
      rollNumber: rollNumber,
      employeeId: employeeId,
      department: department,
    );
  }
}
