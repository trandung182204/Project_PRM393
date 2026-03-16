import 'package:bai1/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = AuthController();

  // 1. Manage password visibility and loading state
  bool _isObscure = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    // Hide keyboard when Login is clicked
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final response = await _authController.login(
        _phoneController.text.trim(),
        _passwordController.text.trim(),
      );

      debugPrint(
        "=====> API SUCCESS! Role is: ${response.role}",
      ); // Log 2
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/home',
        arguments: response, // Pass data
      );
    } catch (e) {
      debugPrint("=====> ERROR: $e"); // Log 3
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid phone number or password")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(
            20.0,
          ), // Căn lề đều và rộng hơn một chút cho đẹp
          child: Column(
            children: [
              const SizedBox(height: 40), // Push form down to avoid notch/status bar
              Column(
                children: [
                  const Image(
                    height: 150,
                    image: AssetImage('assets/icon/student_hub_logo.png'),
                  ),
                  const SizedBox(height: 10),
                  const Column(
                    children: [
                      Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Welcome to StudentHub"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone, // Open numeric keyboard
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone,
                        ), // 2. Changed from prefix to prefixIcon
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText:
                          _isObscure, // 3. Bound to _isObscure variable
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock,
                        ), // Dùng icon lock cho pass hợp lý hơn
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        // 4. Changed suffix to suffixIcon and used IconButton for interactivity
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure; // Toggle state
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .end, // Align Forgot Password text to the right
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/forgot_password');
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50, // Fixed button height
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        // 5. Lock button while loading
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
