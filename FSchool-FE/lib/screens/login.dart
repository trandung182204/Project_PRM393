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

  // 1. Thêm biến quản lý ẩn/hiện mật khẩu và trạng thái Loading
  bool _isObscure = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    // Ẩn bàn phím khi bấm Login
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final response = await _authController.login(
        _phoneController.text.trim(),
        _passwordController.text.trim(),
      );

      debugPrint(
        "=====> API THÀNH CÔNG! ClassId là: ${response.role}",
      ); // Log 2
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/home',
        arguments: response, // Gửi data đi
      );
    } catch (e) {
      debugPrint("=====> LỖI RỒI: $e"); // Log 3
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sai tài khoản hoặc mật khẩu")),
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
              const SizedBox(
                height: 40,
              ), // Đẩy form xuống một chút tránh vướng tai thỏ/status bar
              Column(
                children: [
                  const Image(
                    height: 150,
                    image: NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNkwDjcK0EsrsVg_I-HsRnivHuIkBcsfyitw&s',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: const [
                      Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Welcome to FSchool"),
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
                      keyboardType: TextInputType.phone, // Mở sẵn bàn phím số
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone,
                        ), // 2. Sửa từ prefix -> prefixIcon
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText:
                          _isObscure, // 3. Ràng buộc với biến _isObscure
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock,
                        ), // Dùng icon lock cho pass hợp lý hơn
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        // 4. Sửa suffix -> suffixIcon và dùng IconButton để bấm được
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure; // Đảo ngược trạng thái
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .end, // Ép chữ Forgot Password sang phải
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/forgot_password');
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50, // Cố định chiều cao nút bấm
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        // 5. Khóa nút khi đang load
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
