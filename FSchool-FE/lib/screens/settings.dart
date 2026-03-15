import 'package:flutter/material.dart';
import 'package:bai1/widgets/custom_bottom_nav_bar.dart';
import 'package:bai1/controllers/auth_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController _authController = AuthController();
    final args = ModalRoute.of(context)?.settings.arguments as dynamic;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // User Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          args?.fullName ?? 'User Name',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Role: ${args?.role ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (args?.role == 'Student')
                          Text(
                            'Roll Number: ${args?.rollNumber ?? 'N/A'}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        if (args?.role == 'Staff' || args?.role == 'Admin') ...[
                          if (args?.employeeId != null)
                            Text(
                              'Employee ID: ${args?.employeeId}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          if (args?.department != null)
                            Text(
                              'Department: ${args?.department}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),

            _buildSettingsItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature not implemented yet')),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.notifications_none,
              title: 'Notifications',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: 'About App',
              onTap: () {},
            ),

            const SizedBox(height: 32),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _authController.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'LOGOUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
        args: args,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
