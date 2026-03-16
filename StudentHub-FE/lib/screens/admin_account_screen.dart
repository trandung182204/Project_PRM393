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
          const SnackBar(content: Text('Account created successfully!')),
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
        title: const Text('Create New Account'),
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
                'Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Please enter phone number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Please enter email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Please enter password' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Please enter full name' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Role',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Student',
                    groupValue: _selectedRole,
                    onChanged: (v) => setState(() => _selectedRole = v!),
                  ),
                  const Text('Student'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'Staff',
                    groupValue: _selectedRole,
                    onChanged: (v) => setState(() => _selectedRole = v!),
                  ),
                  const Text('Staff/Teacher'),
                ],
              ),
              const SizedBox(height: 16),
              if (_selectedRole == 'Student')
                TextFormField(
                  controller: _rollNumberController,
                  decoration: const InputDecoration(labelText: 'Student ID', border: OutlineInputBorder()),
                ),
              if (_selectedRole == 'Staff') ...[
                TextFormField(
                  controller: _employeeIdController,
                  decoration: const InputDecoration(labelText: 'Employee ID', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
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
                  child: _isLoading ? const CircularProgressIndicator() : const Text('CREATE ACCOUNT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
