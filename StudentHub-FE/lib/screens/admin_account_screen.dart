import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';

class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({super.key});

  @override
  State<AdminAccountScreen> createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminController = AdminController();

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();

  String _selectedRole = 'Student';
  bool _isLoading = false;

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _adminController.createAccount(
        phoneNumber: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _fullNameController.text,
        role: _selectedRole,
        rollNumber: _selectedRole == 'Student' ? _rollNumberController.text : null,
        employeeId: _selectedRole == 'Staff' ? _employeeIdController.text : null,
        department: _selectedRole == 'Staff' ? _departmentController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo tài khoản thành công!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo tài khoản mới'),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin cơ bản',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder()),
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Họ và tên', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập họ và tên' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Vai trò',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Student',
                    groupValue: _selectedRole,
                    onChanged: (v) => setState(() => _selectedRole = v!),
                  ),
                  const Text('Sinh viên'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'Staff',
                    groupValue: _selectedRole,
                    onChanged: (v) => setState(() => _selectedRole = v!),
                  ),
                  const Text('Nhân viên/Giáo viên'),
                ],
              ),
              const SizedBox(height: 16),
              if (_selectedRole == 'Student')
                TextFormField(
                  controller: _rollNumberController,
                  decoration: const InputDecoration(labelText: 'MSSV', border: OutlineInputBorder()),
                ),
              if (_selectedRole == 'Staff') ...[
                TextFormField(
                  controller: _employeeIdController,
                  decoration: const InputDecoration(labelText: 'Mã nhân viên', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(labelText: 'Phòng ban', border: OutlineInputBorder()),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCreateAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading ? const CircularProgressIndicator() : const Text('TẠO TÀI KHOẢN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
